# JSON Reference

## Naming Conventions
- Choose one convention and enforce everywhere. Use camelCase for JavaScript/browser-facing APIs; use snake_case for Python/Ruby-facing APIs.
- Start names with a letter, underscore, or dollar sign. Use digits only in subsequent characters.
- Use plural names for array-valued properties (`"users"`, `"items"`); use singular for everything else.
- Make names meaningful and self-descriptive. Avoid abbreviations without context.

## Schema Design
- Define schemas using JSON Schema with `$schema` to declare the draft version.
- Use `$defs` for reusable sub-schemas. Reference them with `$ref`.
- Give sub-schemas meaningful names (e.g., `AddressType`, `MoneyType`).
- Specify `type` on every property.
- Use `format` for strings: `"email"`, `"uri"`, `"date-time"`, `"uuid"`.
- List mandatory properties in `required`.
- Add `description` to every property for self-documenting schemas.
- Use `enum` as strings (not integers) for enumerated values to allow graceful extension.
- Version schemas to maintain backward compatibility.

## Null Handling
- Omit optional properties with null/empty values unless null carries explicit semantic meaning (e.g., "intentionally cleared").
- Never use `null` for booleans. Use a string enum if a third state is needed (`"yes"`, `"no"`, `"unknown"`).
- Include `0` when it carries meaning (e.g., zero balance). Do not omit it.
- In schema, use `"type": ["string", "null"]` when a property can legitimately be null.
- Never use empty string `""` as a null substitute.

## Date/Time Formatting
- Always use RFC 3339 / ISO 8601: `"2026-03-28T14:30:00.000Z"`.
- Store and transmit all timestamps in UTC (trailing `Z` or `+00:00`).
- Use `YYYY-MM-DD` for date-only values.
- Use ISO 8601 durations for time spans: `"P3Y6M4DT12H30M5S"`.
- Suffix date-time property names with `At`: `createdAt`, `updatedAt`, `deletedAt`.
- Suffix date-only property names with `Date` or `On`: `birthDate`, `publishedOn`.
- Never use Unix timestamps as primary format. Precision is ambiguous (seconds vs milliseconds).

## Structure: Nested vs Flat
- Default to flat. Flatten unless nesting has clear semantic meaning.
- Nest when grouped properties represent a single coherent entity (e.g., `"address": { "street": "...", "city": "..." }`).
- Avoid nesting deeper than 3 levels.
- For related collections, prefer flat arrays with IDs and separate top-level keys over deep embedding.
- Use `kind` or `type` as the first property in objects to aid parsers.
- Place collection arrays (`items`) as the last property in the parent object.

## Error Responses
- Structure consistently: `{ "error": { "code": 404, "message": "Not found", "errors": [...] } }`.
- Set error code to an integer HTTP status code. Make message human-readable.
- Include an `errors` array for field-level validation errors with `field`, `message`, and `code`.

## Pagination
- Include `totalItems`, `itemsPerPage`, `startIndex` or cursor fields.
- Use 1-based page indexing for human readability.
- Include navigation links (`next`, `prev`, `self`) where applicable.

## General Rules
- Never add comments in JSON. Use `description` fields in schemas instead.
- Always use double quotes for property names and string values.
- Do not quote boolean or number values.
- Include `self`/`selfLink` for resource URLs in responses.
