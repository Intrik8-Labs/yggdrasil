# Týr — Initial Domain and Identity Design

## Purpose

This document turns the high-level requirements in `TYR.md` into an initial implementation design for the first Týr slice.

It is intentionally a starting design rather than a permanent schema. Domain boundaries should be revised when real behavior, concurrency, security, or operational requirements demonstrate a better model.

## Initial Technology Decisions

For the first Týr implementation:

- use ASP.NET Core Identity for local authentication infrastructure
- use EF Core for persistence
- do not make `IdentityUser` the Týr domain `User`
- do not implement custom password hashing
- do not initially create a domain `LocalCredential`
- prefer secure cookie authentication for the first browser application
- keep authentication infrastructure behind Týr boundaries
- keep tenant membership and authorization as Yggdrasil domain concepts

ASP.NET Core Identity answers:

> Can this actor prove who they are?

Týr answers:

> What Yggdrasil identity does this actor represent, which tenants do they belong to, and what are they permitted to do?

## Layer Responsibilities

```text
Týr Core
├── User
├── Membership
├── Role
├── Permission
└── domain rules

Týr UseCases
├── authentication orchestration
├── membership management
├── role management
└── authorization resolution

Týr Infrastructure
├── ASP.NET Core Identity
├── EF Core
├── authentication persistence
├── password hashing
└── Identity stores

Host
├── authentication middleware
├── cookie/token configuration
├── login endpoints
└── logout endpoints
```

## Core Domain Types

### Identifier Value Objects

Use explicit identifiers rather than passing raw `Guid` values throughout the model.

```csharp
public readonly record struct UserId(Guid Value)
{
    public static UserId New() => new(Guid.NewGuid());
}

public readonly record struct MembershipId(Guid Value)
{
    public static MembershipId New() => new(Guid.NewGuid());
}

public readonly record struct RoleId(Guid Value)
{
    public static RoleId New() => new(Guid.NewGuid());
}
```

`TenantId` should likely live in `Yggdrasil.SharedKernel` because the concept has the same meaning across tenant-aware modules.

```csharp
public readonly record struct TenantId(Guid Value)
{
    public static TenantId New() => new(Guid.NewGuid());
}
```

Potential future identifiers include `ServiceIdentityId` and `CredentialId`, but they are not required for the first slice.

## User Aggregate

`User` represents the Yggdrasil human identity and lifecycle, not ASP.NET Core Identity persistence.

```csharp
public sealed class User : AggregateRoot<UserId>
{
    public EmailAddress Email { get; private set; }

    public string DisplayName { get; private set; }

    public UserStatus Status { get; private set; }

    public DateTimeOffset CreatedAt { get; }

    public DateTimeOffset UpdatedAt { get; private set; }

    // Domain behavior added as requirements are implemented.
}
```

Initial status:

```csharp
public enum UserStatus
{
    Active,
    Disabled
}
```

### EmailAddress

Email should be a small value object so normalization and validation rules do not spread through the application.

```csharp
public sealed record EmailAddress
{
    public string Value { get; }

    private EmailAddress(string value)
    {
        Value = value;
    }

    public static Result<EmailAddress> Create(string value)
    {
        // Normalize and validate.
        throw new NotImplementedException();
    }
}
```

The exact validation rules should be deliberately modest. Do not attempt to implement the full email RFC grammar in the domain.

## Membership Aggregate

Membership represents the relationship between one User and one Tenant.

```csharp
public sealed class Membership : AggregateRoot<MembershipId>
{
    private readonly HashSet<RoleId> _roleIds = [];

    public UserId UserId { get; }

    public TenantId TenantId { get; }

    public MembershipStatus Status { get; private set; }

    public IReadOnlySet<RoleId> RoleIds => _roleIds;

    public Membership(
        MembershipId id,
        UserId userId,
        TenantId tenantId)
        : base(id)
    {
        UserId = userId;
        TenantId = tenantId;
        Status = MembershipStatus.Active;
    }

    public void AssignRole(RoleId roleId)
    {
        _roleIds.Add(roleId);
    }

    public void RemoveRole(RoleId roleId)
    {
        _roleIds.Remove(roleId);
    }

    public void Revoke()
    {
        Status = MembershipStatus.Revoked;
    }
}
```

Initial membership lifecycle:

```csharp
public enum MembershipStatus
{
    Pending,
    Active,
    Suspended,
    Revoked
}
```

A User being active does not grant tenant access. The Membership must also be valid and active.

## Role Aggregate

A Role represents a tenant-scoped named collection of permissions.

```csharp
public sealed class Role : AggregateRoot<RoleId>
{
    private readonly HashSet<Permission> _permissions = [];

    public TenantId TenantId { get; }

    public string Name { get; private set; }

    public IReadOnlySet<Permission> Permissions => _permissions;

    public Role(
        RoleId id,
        TenantId tenantId,
        string name)
        : base(id)
    {
        TenantId = tenantId;
        Name = name;
    }

    public void Grant(Permission permission)
    {
        _permissions.Add(permission);
    }

    public void Revoke(Permission permission)
    {
        _permissions.Remove(permission);
    }
}
```

Role names must never become authorization logic. Code evaluates permissions rather than checking for strings such as `Admin`.

## Permission Value Object

Permissions can initially be modeled as stable value objects rather than database entities.

```csharp
public readonly record struct Permission(string Value)
{
    public override string ToString() => Value;
}
```

Known platform permissions should be declared centrally.

```csharp
public static class Permissions
{
    public static class Mimir
    {
        public static readonly Permission TaskRead =
            new("mimir.task.read");

        public static readonly Permission TaskCreate =
            new("mimir.task.create");

        public static readonly Permission TaskAssign =
            new("mimir.task.assign");
    }

    public static class Valhalla
    {
        public static readonly Permission OrganizationManage =
            new("valhalla.organization.manage");
    }

    public static class Urd
    {
        public static readonly Permission AuditRead =
            new("urd.audit.read");
    }
}
```

## ASP.NET Core Identity Boundary

The Týr domain User should remain separate from the ASP.NET Core Identity persistence model.

Infrastructure may define an internal Identity model:

```csharp
internal sealed class ApplicationUser : IdentityUser<Guid>
{
    public Guid DomainUserId { get; set; }
}
```

`ApplicationUser` may contain Identity-specific state such as:

- password hash
- security stamp
- concurrency stamp
- lockout information
- MFA configuration
- normalized email/username
- external-login records

Other modules must never reference `ApplicationUser`.

The relationship between `ApplicationUser` and the domain `User` should remain deliberately simple and one-to-one for local authentication.

## Credential Ownership

Týr Core should not initially contain a `LocalCredential` entity.

ASP.NET Core Identity owns local authentication mechanics including:

```text
PasswordHash
SecurityStamp
Lockout
PasswordResetTokens
MFAState
ExternalLoginData
```

The domain should not understand password-hash format or Identity implementation details.

If future service identities or API credentials require real domain lifecycle behavior, introduce those concepts separately when required.

## Authentication Abstraction

UseCases may expose a narrow abstraction over local authentication infrastructure.

```csharp
public interface ILocalAuthenticationService
{
    Task<AuthenticationResult> AuthenticateAsync(
        string email,
        string password,
        CancellationToken cancellationToken);
}
```

```csharp
public sealed record AuthenticationResult(
    bool Succeeded,
    UserId? UserId);
```

Infrastructure implements this using appropriate ASP.NET Core Identity services.

Do not recreate the complete Identity API behind custom abstractions.

## Authentication Flow

Initial local login:

```text
POST /auth/login
        ↓
Login endpoint
        ↓
Authenticate use case
        ↓
ASP.NET Core Identity
        ↓
credentials verified
        ↓
resolve Týr User
        ↓
verify User is active
        ↓
resolve available Memberships
        ↓
establish authenticated session
```

Example request:

```csharp
public sealed record LoginRequest(
    string Email,
    string Password);
```

Example command/result:

```csharp
public sealed record AuthenticateCommand(
    string Email,
    string Password)
    : ICommand<AuthenticateResult>;
```

```csharp
public sealed record AuthenticateResult(
    UserId UserId,
    string DisplayName,
    IReadOnlyList<MembershipSummary> Memberships);
```

The UseCase result describes successful Yggdrasil authentication. It should not expose an ASP.NET authentication ticket, cookie, or Identity-specific type.

## Login and Logout Host Responsibilities

The host owns HTTP and session mechanics.

Conceptual login endpoint:

```csharp
app.MapPost(
    "/auth/login",
    async (
        LoginRequest request,
        ICommandHandler<AuthenticateCommand, AuthenticateResult> handler,
        CancellationToken cancellationToken) =>
    {
        var command = new AuthenticateCommand(
            request.Email,
            request.Password);

        var result = await handler.HandleAsync(
            command,
            cancellationToken);

        // Host establishes the actual authentication session.

        return Results.Ok(result);
    });
```

Conceptual logout:

```text
POST /auth/logout
        ↓
authentication session invalidated
        ↓
security context cleared
```

ASP.NET Core Identity/authentication middleware performs actual session invalidation.

For example:

```csharp
await signInManager.SignOutAsync();
```

Logout may also produce an audit event where policy requires it.

## Session Choice

For the initial browser application, prefer secure server-managed cookie authentication rather than defaulting immediately to JWTs.

Different clients may eventually use different mechanisms:

```text
Browser
→ secure authentication cookie

External API
→ scoped access token

Smidr Agent
→ certificate/service credential

External Identity Provider
→ OpenID Connect

High-assurance deployment
→ federated identity + MFA and/or certificate-backed authentication
```

The authentication mechanism must remain separate from the Týr domain identity model.

## Current Actor Context

The active actor/tenant context belongs in the application boundary rather than the domain model.

Possible abstraction:

```csharp
public interface ICurrentActor
{
    UserId? UserId { get; }
    TenantId? TenantId { get; }
    MembershipId? MembershipId { get; }
    bool IsAuthenticated { get; }
}
```

Once established, this trusted context should drive authorization and tenant-aware use cases rather than accepting arbitrary user/tenant IDs from request bodies.

## Authorization Resolution

Authorization can initially resolve effective permissions through membership roles.

```text
Membership
→ Role IDs
→ Roles
→ Permissions
```

Possible application abstraction:

```csharp
public interface IEffectivePermissionResolver
{
    Task<IReadOnlySet<Permission>> ResolveAsync(
        MembershipId membershipId,
        CancellationToken cancellationToken);
}
```

Normal use cases may expose a simpler checker based on current actor context:

```csharp
public interface IPermissionChecker
{
    Task<bool> HasPermissionAsync(
        Permission permission,
        CancellationToken cancellationToken);
}
```

Do not optimize or cache permission resolution until profiling/operational requirements justify it.

## Repository Contracts

Use explicit domain repositories rather than a generic `IRepository<T>`.

Example:

```csharp
public interface IUserRepository
{
    Task<User?> GetByIdAsync(
        UserId id,
        CancellationToken cancellationToken);

    Task<User?> GetByEmailAsync(
        EmailAddress email,
        CancellationToken cancellationToken);

    Task AddAsync(
        User user,
        CancellationToken cancellationToken);
}
```

```csharp
public interface IMembershipRepository
{
    Task<Membership?> GetAsync(
        UserId userId,
        TenantId tenantId,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<Membership>> ListForUserAsync(
        UserId userId,
        CancellationToken cancellationToken);
}
```

```csharp
public interface IRoleRepository
{
    Task<Role?> GetByIdAsync(
        RoleId id,
        CancellationToken cancellationToken);
}
```

## Domain Events

Initial domain events may include:

```csharp
public sealed record UserCreated(UserId UserId);
public sealed record UserDisabled(UserId UserId);

public sealed record MembershipCreated(
    MembershipId MembershipId,
    UserId UserId,
    TenantId TenantId);

public sealed record MembershipRevoked(
    MembershipId MembershipId,
    UserId UserId,
    TenantId TenantId);

public sealed record RoleAssigned(
    MembershipId MembershipId,
    RoleId RoleId);
```

Domain events and public integration events are different types even when their names are similar.

A domain event may remain entirely inside Týr. An integration event belongs to `Yggdrasil.Tyr.Contracts` and forms a cross-module boundary.

## EF Core Persistence

EF Core should be introduced when Týr reaches Infrastructure.

The domain model remains designed independently from EF Core.

A single Týr `DbContext` may initially host both Týr domain persistence and ASP.NET Core Identity tables if this materially simplifies implementation.

That decision can be revisited if operational/security requirements justify separating stores.

## Proposed Project/File Layout

### Core

```text
Yggdrasil.Tyr.Core/
├── Users/
│   ├── User.cs
│   ├── UserId.cs
│   ├── UserStatus.cs
│   ├── EmailAddress.cs
│   └── Events/
│       ├── UserCreated.cs
│       └── UserDisabled.cs
│
├── Memberships/
│   ├── Membership.cs
│   ├── MembershipId.cs
│   ├── MembershipStatus.cs
│   └── Events/
│       ├── MembershipCreated.cs
│       └── MembershipRevoked.cs
│
├── Roles/
│   ├── Role.cs
│   ├── RoleId.cs
│   ├── Permission.cs
│   └── Events/
│       ├── RoleAssigned.cs
│       └── RoleRemoved.cs
│
└── Interfaces/
    ├── IUserRepository.cs
    ├── IMembershipRepository.cs
    └── IRoleRepository.cs
```

Do not add generic `Services`, `Managers`, `Helpers`, `Utils`, or `Factories` folders without a concrete design need.

### UseCases

```text
Yggdrasil.Tyr.UseCases/
├── Users/
│   ├── BootstrapAdmin/
│   ├── GetCurrentUser/
│   └── DisableUser/
│
├── Authentication/
│   ├── Authenticate/
│   │   ├── AuthenticateCommand.cs
│   │   ├── AuthenticateHandler.cs
│   │   └── AuthenticateResult.cs
│   └── ILocalAuthenticationService.cs
│
├── Memberships/
│   ├── Create/
│   ├── ListForUser/
│   ├── SelectActive/
│   └── Revoke/
│
└── Authorization/
    ├── CheckPermission/
    └── IEffectivePermissionResolver.cs
```

### Infrastructure

```text
Yggdrasil.Tyr.Infrastructure/
├── Authentication/
│   ├── LocalAuthenticationService.cs
│   └── AuthenticationConfiguration.cs
│
├── Identity/
│   ├── ApplicationUser.cs
│   └── IdentityConfiguration.cs
│
├── Data/
│   ├── TyrDbContext.cs
│   ├── Configurations/
│   │   ├── UserConfiguration.cs
│   │   ├── MembershipConfiguration.cs
│   │   └── RoleConfiguration.cs
│   └── Migrations/
│
├── Repositories/
│   ├── UserRepository.cs
│   ├── MembershipRepository.cs
│   └── RoleRepository.cs
│
└── DependencyInjection.cs
```

### Contracts

```text
Yggdrasil.Tyr.Contracts/
├── Users/
│   └── UserSummary.cs
│
├── Memberships/
│   └── MembershipSummary.cs
│
├── Authorization/
│   ├── Permission.cs
│   └── PermissionCheckResult.cs
│
└── Events/
    ├── UserCreated.cs
    ├── UserDisabled.cs
    ├── MembershipCreated.cs
    ├── MembershipRevoked.cs
    ├── RoleAssigned.cs
    └── RoleRemoved.cs
```

## Initial Implementation Order

```text
1. UserId
2. MembershipId
3. RoleId
4. TenantId in SharedKernel
5. EmailAddress
6. UserStatus
7. User
8. User domain tests

9. MembershipStatus
10. Membership
11. Membership domain tests

12. Permission
13. Role
14. Role/permission domain tests

15. Týr repository contracts
16. Týr UseCases skeleton

17. EF Core persistence
18. ASP.NET Core Identity integration
19. local login
20. logout
21. active tenant context
22. permission resolution
23. authorization policies
24. integration/security tests
```

This sequence establishes the Yggdrasil identity model first while introducing ASP.NET Core Identity and EF Core early enough to deliver real authentication rather than building a theoretical domain in isolation.

## Design Risks to Watch

### Duplicate User Models

Separating `ApplicationUser` from Týr `User` is intentional, but it can become unnecessary duplication if both models accumulate the same business/profile properties.

Rule:

- Identity-specific authentication state stays on `ApplicationUser`.
- Yggdrasil business identity/lifecycle state stays on `User`.

Keep the link simple and do not synchronize duplicated fields unnecessarily.

### Rebuilding Identity

Do not introduce custom abstractions that merely recreate `UserManager`, `SignInManager`, password hashing, or token generation.

Wrap only the narrow capabilities that UseCases genuinely need.

### Authorization Through Roles

Roles organize permissions. Roles themselves are not the authorization contract.

Business code checks permissions/capabilities, not role names.

### Premature Complexity

Do not implement initially:

- explicit DENY evaluation
- role versioning
- service identities
- API-key management
- SAML
- passkeys
- SCIM
- complex MFA policy
- impersonation

The design must leave room for them without making the MVP depend on them.

## Related Documentation

- `docs/modules/TYR.md`
- `docs/modules/VALHALLA.md`
- `docs/modules/URD.md`
- `docs/architecture/SECURITY.md`
- `docs/architecture/dependency-rules.md`
- `docs/development/TESTING.md`
