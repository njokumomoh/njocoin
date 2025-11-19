# njocoin

Njocoin is a simple fungible token implemented as a Clarity smart contract
and managed with [Clarinet](https://github.com/hirosystems/clarinet). This
repository contains the contract source code, local development configuration,
and a basic testing setup.

## Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) (CLI) installed and on your `PATH`  
  You can verify this with:

  ```bash path=null start=null
  clarinet --version
  ```

- Node.js (for running the generated TypeScript tests with Vitest), if you
  plan to use the test harness.

## Project structure

- `Clarinet.toml` – Clarinet project configuration
- `contracts/njocoin.clar` – Njocoin fungible token contract
- `settings/` – Network configuration files for Devnet, Testnet, and Mainnet
- `tests/` – TypeScript tests executed with Vitest
- `package.json`, `tsconfig.json`, `vitest.config.ts` – JS/TS tooling

## Contract overview

The Njocoin contract is a simple fungible token using Clarity's built-in
fungible token primitives.

Key features:

- `define-fungible-token njocoin` – defines the Njocoin token
- Read-only metadata:
  - `get-name` – returns the token name (`"Njocoin"`)
  - `get-symbol` – returns the token symbol (`"NJO"`)
  - `get-decimals` – returns the number of decimals (currently `u6`)
- Supply and balances:
  - `get-total-supply` – returns the total amount of tokens minted
  - `get-balance (who)` – returns the balance of a given principal
- Public actions:
  - `mint (amount)` – mints `amount` tokens to the caller (`tx-sender`)
  - `transfer (amount sender recipient)` – transfers tokens from `sender`
    to `recipient` (only allowed if `sender == tx-sender`)

> **Note:** The `mint` function in this example behaves like a faucet – any
> principal can mint tokens to themselves. For production usage you would
> typically restrict minting to a contract owner or governance mechanism.

## Usage

### 1. Clone and enter the project

If you haven't already:

```bash path=null start=null
git clone <your-repo-url> njocoin
cd njocoin
```

### 2. Verify Clarinet is available

```bash path=null start=null
clarinet --version
```

You should see a version string (for example `clarinet 3.x.x`).

### 3. Run static checks

From the project root (where `Clarinet.toml` lives):

```bash path=null start=null
clarinet check
```

This command will parse and type-check all contracts in the `contracts/`
folder and report any errors.

### 4. Interact via the Clarinet console (optional)

You can use the Clarinet console to experiment with contract calls:

```bash path=null start=null
clarinet console
```

Inside the console, you can call functions like:

```clojure path=null start=null
(contract-call? .njocoin mint u1000)
(contract-call? .njocoin transfer u1000 tx-sender 'ST1...)
(read-only (contract-call? .njocoin get-balance 'ST1...))
```

Replace `'ST1...` with an actual principal from the Clarinet simnet.

### 5. Run tests (optional)

The project is preconfigured to use Vitest and the Clarinet JS SDK
for tests located in the `tests/` directory.

Install dependencies and run tests with:

```bash path=null start=null
npm install
npm test
```

## Development notes

- Edit `contracts/njocoin.clar` to extend the token logic (e.g. adding
  burn functionality, admin-restricted minting, or SIP-010 compliance).
- Update or add tests under `tests/` to cover new behavior.
- Always run `clarinet check` before deploying or committing contract
  changes.
