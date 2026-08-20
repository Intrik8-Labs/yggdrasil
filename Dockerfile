FROM mcr.microsoft.com/dotnet/sdk:10.0.400 AS build
WORKDIR /source

COPY global.json Directory.Build.props Directory.Packages.props Yggdrasil.slnx ./
COPY src/Core/Yggdrasil.SharedKernel/Yggdrasil.SharedKernel.csproj src/Core/Yggdrasil.SharedKernel/
COPY src/Core/Yggdrasil.Core.Domain/Yggdrasil.Core.Domain.csproj src/Core/Yggdrasil.Core.Domain/
COPY src/Core/Yggdrasil.Core.Application/Yggdrasil.Core.Application.csproj src/Core/Yggdrasil.Core.Application/
COPY src/Core/Yggdrasil.Core.Infrastructure/Yggdrasil.Core.Infrastructure.csproj src/Core/Yggdrasil.Core.Infrastructure/
COPY src/Modules/Mimir/Yggdrasil.Mimir.Domain/Yggdrasil.Mimir.Domain.csproj src/Modules/Mimir/Yggdrasil.Mimir.Domain/
COPY src/Modules/Mimir/Yggdrasil.Mimir.Application/Yggdrasil.Mimir.Application.csproj src/Modules/Mimir/Yggdrasil.Mimir.Application/
COPY src/Modules/Mimir/Yggdrasil.Mimir.Infrastructure/Yggdrasil.Mimir.Infrastructure.csproj src/Modules/Mimir/Yggdrasil.Mimir.Infrastructure/
COPY src/Host/Yggdrasil.Api/Yggdrasil.Api.csproj src/Host/Yggdrasil.Api/
RUN dotnet restore src/Host/Yggdrasil.Api/Yggdrasil.Api.csproj

COPY src/ src/
RUN dotnet publish src/Host/Yggdrasil.Api/Yggdrasil.Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0.11 AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
USER app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Yggdrasil.Api.dll"]
