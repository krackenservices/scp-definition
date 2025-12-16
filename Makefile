# SCP Definition Makefile
# Specification and schema validation
#
# Requires: uv tool install check-jsonschema

.PHONY: help validate validate-schema lint clean

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

validate: ## Validate all example scp.yaml files against the schema
	check-jsonschema --schemafile spec/scp.schema.json examples/*/scp.yaml

validate-schema: ## Validate the JSON schema itself
	check-jsonschema --check-metaschema spec/scp.schema.json

lint: ## Lint YAML files
	@echo "Linting YAML files..."
	yamllint examples/ || true

clean: ## Clean generated files
	@echo "Nothing to clean"
