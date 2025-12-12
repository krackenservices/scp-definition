# System Capability Protocol (SCP)

A machine-first system architecture description protocol enabling LLMs, observability tooling, and alerting systems to reason about distributed systems.

## What is SCP?

SCP provides a declarative manifest format (`scp.yaml`) that describes what a system *should* be, complementing OpenTelemetry's view of what *is happening*.

```yaml
# scp.yaml
scp: "0.1.0"

system:
  urn: "urn:scp:acme:payment-service"
  name: "Payment Service"
  classification:
    tier: 1
    domain: "payments"

ownership:
  team: "payments-platform"

provides:
  - capability: "payment-processing"
    type: "rest"
    contract:
      type: "openapi"
      ref: "./api/openapi.yaml"

depends:
  - system: "urn:scp:acme:user-service"
    type: "rest"
    criticality: "required"
    failure_mode: "fail-fast"

runtime:
  environments:
    production:
      otel_service_name: "payment-service"
```

## Key Features

- **LLM Reasoning**: Enables change impact analysis and migration planning
- **Architecture Discovery**: Scan repos to generate org-wide system maps
- **Theory vs Reality**: Diff declared dependencies against OTel traces
- **Smart Alerting**: Auto-enrich alerts with ownership and blast radius

## Repository Structure

```
scp-definition/
├── spec/
│   ├── scp.schema.json      # JSON Schema for validation
│   ├── scp-v0.1.md          # Specification document
│   └── graph-model.md       # Graph model specification
├── examples/
│   ├── payment-service/     # Tier 1 example
│   ├── order-service/       # Event publishing example
│   └── user-service/        # External auth example
├── integrations/
│   ├── otel/                # OpenTelemetry diff
│   ├── alerting/            # Alert enrichment
│   └── llm/                 # LLM usage patterns
└── README.md
```

## Quick Start

### 1. Create `scp.yaml`

Add a manifest to your repository root. See [spec/scp-v0.1.md](spec/scp-v0.1.md) for all fields.

### 2. Validate

```bash
npx ajv validate -s spec/scp.schema.json -d scp.yaml
```

### 3. Build Graph

Parse all `scp.yaml` files to build an org-wide dependency graph.

## Design Principles

| Principle | Description |
|-----------|-------------|
| **Machine-first** | Schemas over prose, deterministic parsing |
| **Minimal v0** | Essential fields only, avoid over-engineering |
| **Composable** | Works alongside OpenAPI, AsyncAPI, OTel |
| **Late-bound** | Supports partial adoption |
| **Reality-aware** | Join points with observability data |

## Documentation

- [Specification](spec/scp-v0.1.md) - Complete manifest format
- [Graph Model](spec/graph-model.md) - Neo4j schema and queries
- [OTel Integration](integrations/otel/diff-algorithm.md) - Theory vs reality diff
- [Alerting](integrations/alerting/enrichment.md) - Alert enrichment
- [LLM Patterns](integrations/llm/usage-patterns.md) - AI-assisted architecture

## License

MIT
