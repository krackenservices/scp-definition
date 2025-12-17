# System Capability Protocol (SCP) v0.1.0

A machine-first system architecture description protocol enabling LLMs, observability tooling, and alerting systems to reason about distributed systems.

## Overview

SCP provides a declarative manifest format (`scp.yaml`) that describes what a system *should* be, complementing OpenTelemetry's view of what *is happening*. Each repository contains a single `scp.yaml` at its root.

## Quick Start

```yaml
# scp.yaml
scp: "0.1.0"

system:
  urn: "urn:scp:my-service:api"
  name: "My Service"
  description: "Does important things"
  classification:
    tier: 2
    domain: "platform"

ownership:
  team: "platform-team"
  contacts:
    - type: "slack"
      ref: "slack://channel/C123PLATFORM"

provides:
  - capability: "my-api"
    type: "rest"
    contract:
      type: "openapi"
      ref: "./api/openapi.yaml"

depends:
  - system: "urn:scp:database:primary"
    type: "data"
    criticality: "required"
    failure_mode: "fail-fast"

runtime:
  environments:
    production:
      otel_service_name: "my-service"
```

## Specification

### System Identity

Every system has a stable URN that survives renames and repository moves:

```
urn:scp:<service-name>:<component-name>
```

| Field | Required | Description |
|-------|----------|-------------|
| `urn` | Yes | Immutable system identifier |
| `name` | Yes | Human-readable name |
| `description` | No | Brief purpose description |
| `version` | No | Semantic version |
| `classification.tier` | No | Criticality (1=critical, 5=experimental) |
| `classification.domain` | No | Business domain |
| `classification.tags` | No | Classification tags |

### Ownership

```yaml
ownership:
  team: "team-identifier"           # Required
  contacts:
    - type: "oncall|slack|email|pagerduty|opsgenie"
      ref: "uri-to-contact"
  escalation:
    - "team-1"
    - "team-2"
```

### Provided Capabilities

Capabilities are what your system offers to others:

```yaml
provides:
  - capability: "payment-processing"
    type: "rest|grpc|graphql|event|data|stream"
    contract:
      type: "openapi|asyncapi|protobuf|graphql|avro"
      ref: "./path/to/spec.yaml"
    sla:
      availability: "99.95%"
      latency_p99_ms: 500
    topics:                          # For event types
      - "payments.completed"
```

### Security Extensions (x-security)

For security tools (EDR, SIEM, SOAR, etc.), the `x-security` extension describes actionable capabilities for automation:

```yaml
provides:
  - capability: "host-containment"
    type: "rest"
    contract:
      type: "openapi"
      ref: "./api/containment.yaml"
    x-security:
      actuator_profile: "edr"              # OpenC2 actuator type
      actions: ["contain", "allow", "query"]  # Supported actions
      targets: ["hostname", "device_id"]   # Target types
```

| Field | Description |
|-------|-------------|
| `actuator_profile` | OpenC2-inspired profile: `edr`, `siem`, `slpf`, `soar` |
| `actions` | Supported actions: `query`, `contain`, `deny`, `allow`, `remediate`, `notify` |
| `targets` | Target types: `hostname`, `ipv4_addr`, `file`, `process`, `ioc`, etc. |

This enables SOAR platforms to auto-discover what security tools can do. Use `scp-cli scan --export openc2` to generate an actuator inventory.


### Dependencies

Dependencies define what your system consumes:

```yaml
depends:
  - system: "urn:scp:other-service:api"
    capability: "capability-name"    # Optional
    type: "rest|grpc|event|data"
    criticality: "required|degraded|optional"
    failure_mode: "fail-fast|circuit-break|fallback|queue-buffer"
    timeout_ms: 1000
    retry:
      max_attempts: 3
      backoff: "exponential"
    circuit_breaker:
      failure_threshold: 5
      reset_timeout_ms: 30000
```

**Criticality levels:**
- `required`: System cannot function without this dependency
- `degraded`: System continues with reduced functionality
- `optional`: System fully functional without this dependency

### Constraints

```yaml
constraints:
  security:
    authentication: ["oauth2", "mtls"]
    data_classification: "pci-dss"
    encryption:
      at_rest: true
      in_transit: true
  compliance:
    frameworks: ["pci-dss", "soc2"]
    data_residency: ["us-east", "eu-west"]
    retention_days: 2555
  operational:
    max_replicas: 20
    min_replicas: 3
    deployment_windows:
      - "weekdays 09:00-17:00 UTC"
```

### Runtime Bindings

Runtime bindings connect the abstract system to concrete deployments:

```yaml
runtime:
  environments:
    production:
      otel_service_name: "my-service"  # Join key for OTel traces
      endpoints:
        - "https://api.example.com"
      kubernetes:
        namespace: "production"
        deployment: "my-service"
    staging:
      otel_service_name: "my-service-staging"
```

The `otel_service_name` field is critical — it's the join key for correlating declared architecture with observed OpenTelemetry traces.

### Failure Modes

Document known failure scenarios:

```yaml
failure_modes:
  - mode: "database-unavailable"
    impact: "total-outage|partial-outage|degraded-experience"
    detection: "health-check"
    recovery: "auto-failover"
    degraded_behavior: "Returns cached data for reads"
    mttr_target_minutes: 5
```

## URN Conventions

| Pattern | Usage |
|---------|-------|
| `urn:scp:<service>` | Shorthand for simple single-component services |
| `urn:scp:<service>:<component>` | Internal services |
| `urn:scp:external:<provider>` | External services (Stripe, AWS, etc.) |
| `urn:scp:<service>:database` | Databases |
| `urn:scp:<service>:cache` | Caches |

## Validation

Validate manifests using the JSON Schema:

```bash
# Using ajv-cli
npx ajv validate -s scp.schema.json -d scp.yaml

# Using check-jsonschema
pip install check-jsonschema
check-jsonschema --schemafile scp.schema.json scp.yaml
```

## File Conventions

| File | Purpose |
|------|---------|
| `scp.yaml` | System capability manifest (repo root) |
| `spec/scp.schema.json` | JSON Schema for validation |

## Related Specifications

SCP is designed to complement, not replace:

- **OpenAPI/Swagger**: REST API contracts
- **AsyncAPI**: Event/message contracts  
- **OpenTelemetry**: Runtime observability
- **Kubernetes manifests**: Deployment configuration

SCP references these via the `contract.ref` field rather than embedding them.
