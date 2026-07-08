# Srednoff OS Policies

Policy files are lightweight risk gates for Srednoff OS. They do not replace legal, compliance, finance, or security review.

## Current Policy Set

| Policy | Purpose |
|---|---|
| `ru-data.yml` | Russian personal-data and localization risk gates |
| `ru-payments.yml` | Russian payment and SBP/payment-system risk gates |
| `ru-messaging.yml` | Messenger and customer-data transfer risk gates |
| `ru-marketplaces.yml` | Marketplace, ads, labeling, reviews, and seller data risk gates |
| `neuraldeep.yml` | NeuralDeep/source-import risk gates before registry/importer work |

Use `scripts\srednoff-os-policy-check.ps1` to resolve matching policies for a task brief.
