# LitVM Hard Money Agents

**The first AI agents paid in real Hard Money (zkLTC) on Litecoin's EVM rollup.**

> Autonomous AI agents that earn, hold, and spend **zkLTC** — Litecoin's trustless representation on LitVM.

## Vision

Build the machine economy on **Hard Money**.

- Agents take jobs
- Agents complete verifiable work
- Agents get paid instantly in **zkLTC**
- Agents can compound, hire other agents, or hold for the long term

This repository is designed for maximum hype potential on LitVM mainnet.

### Supported Agent Types

| Agent Type                  | Description                                      | Status     |
|----------------------------|--------------------------------------------------|------------|
| Hard Money Worker          | Core agent paid per task in zkLTC                | Primary    |
| Yield Optimizer            | Autonomous LTC/zkLTC yield manager               | Planned    |
| RWA Underwriter            | AI risk scoring & underwriting for RWAs          | Planned    |
| Sovereign Personal Agent   | User's private economic AI twin                  | Planned    |
| Agent DAO / Treasury       | Fully agent-owned treasury                       | Planned    |

## Network

- **Testnet**: LitVM LiteForge
- **Chain ID**: `4441`
- **Gas Token**: `zkLTC`
- **RPC**: `https://liteforge.rpc.caldera.xyz/http`
- **Explorer**: `https://liteforge.explorer.caldera.xyz`

## Creator / Deployer

**Deployer Address (Owner):**  
`0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10`

All core contracts (`AgentRegistry` & `AgentEscrow`) will be owned by this address at deployment.

> **Important**: Deploy using the private key of this wallet so that `msg.sender` becomes the owner.

---

## Quick Start

### 1. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Clone & Setup

```bash
git clone <your-repo-url>
cd litvm-hardmoney-agents
cp .env.example .env
```

Edit `.env`:
```env
PRIVATE_KEY=0x...          # private key of 0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10
RPC_URL=https://liteforge.rpc.caldera.xyz/http
DEPLOYER_ADDRESS=0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10
```

### 3. Install dependencies

```bash
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std
```

### 4. Compile

```bash
forge build
```

### 5. Test

```bash
forge test -vv
```

### 6. Deploy to LiteForge

```bash
source .env
forge script script/Deploy.s.sol:Deploy \
  --rpc-url $RPC_URL \
  --broadcast \
  --private-key $PRIVATE_KEY \
  -vvvv
```


## Live Contracts (LitVM LiteForge Testnet)

| Contract          | Address                                      | Explorer |
|-------------------|----------------------------------------------|----------|
| **AgentEscrow**   | `0x197B880e387aFC1303dec0306e871035bB470760` | [View](https://liteforge.explorer.caldera.xyz/address/0x197B880e387aFC1303dec0306e871035bB470760) |
| **AgentRegistry** | `0xf3af1633d481dF24a2d9738D7fA697907Eb85b04` | [View](https://liteforge.explorer.caldera.xyz/address/0xf3af1633d481dF24a2d9738D7fA697907Eb85b04) |

**Network:** LitVM LiteForge (Chain ID: 4441)  
**Owner / Creator:** `0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10`

### Registered Agents
- `0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10` → **Pronous**


After successful deployment, the console will show the addresses of `AgentRegistry` and `AgentEscrow`. Save them.

---

## Project Structure

```text
contracts/          → Solidity (Foundry)
  ├── src/core/     → AgentEscrow.sol + AgentRegistry.sol
  ├── script/       → Deploy.s.sol
  └── test/
agents/             → Python AI Agent runtime (coming next)
sdk/                → TypeScript SDK
frontend/           → Optional dashboard
docs/               → Architecture & design docs
```

## License

MIT

---

**Built for LitVM • Hard Money Web3 • AI Agents**  
**Creator: 0x2768ef0331cfde4cab0ffbf989c8f9d622c64c10**
