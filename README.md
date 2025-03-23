# Platformofmemecoins PoC: Missing Events Vulnerability in recoverERC20

## Overview
This Proof of Concept (PoC) demonstrates the "Missing Events" vulnerability in the `recoverERC20` function of the original `Platformofmemecoins` smart contract. The vulnerability occurs because the function transfers tokens out of the contract without emitting a specific event to log the operation, leading to a lack of transparency, especially when recovering non-standard tokens that do not emit a `Transfer` event.

## Files
- `contracts/TestRecoverOriginalPoC.sol`: The Solidity file containing the original `Platformofmemecoins` contract, test tokens (`StandardToken` and `NonStandardToken`), and a `TestRecover` contract to simulate the vulnerability.

## Prerequisites
- [Remix IDE](https://remix.ethereum.org/)
- A browser with MetaMask (optional, for Sepolia Testnet deployment)
- Solidity compiler version `0.8.20`

## Deployment and Testing in Remix

### 1. Setup
1. Open [Remix IDE](https://remix.ethereum.org/).
2. Create a new file: `TestRecoverOriginalPoC.sol` under the `contracts` directory.
3. Copy and paste the content of `TestRecoverOriginalPoC.sol` from this repository into the file.

### 2. Compile
1. Go to the **Solidity Compiler** tab.
2. Select compiler version `0.8.20`.
3. Click **Compile TestRecoverOriginalPoC.sol**.
4. Ensure compilation succeeds with no errors.

### 3. Deploy
1. Go to the **Deploy & Run Transactions** tab.
2. Set **Environment** to **JavaScript VM (London)**.
3. Select `TestRecover` from the contract dropdown.
4. Input parameters:
   - `tokenOwner`: `0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c` (second account in Remix).
   - `feeReceiver`: `0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2` (third account in Remix).
   - `Value`: `1 ether`.
5. Click **Deploy**.

### 4. Verify Initialization
1. Expand the deployed `TestRecover` contract under **Deployed Contracts**.
2. Call `getPlatformOwner`: Should return the deployer address (e.g., `0x5B38...`), as ownership stays with the deployer in this version.
3. Call `getStandardTokenBalance(address(platform))` and `getNonStandardTokenBalance(address(platform))`: Both should return `500000000000000000000` (500 * 10^18).

### 5. Test recoverERC20 with Standard Token
1. Switch to the deployer account (e.g., `0x5B38...`), the owner.
2. Call `recoverStandardToken(500000000000000000000)` (500 * 10^18).
3. Check the logs in the **Terminal**:
   - Expected: A `Transfer` event from `address(platform)` to `0x5B38...` for 500 * 10^18, emitted by `StandardToken`.
   - No event from `recoverERC20`.
4. Analysis: The operation is logged by the token, but not specifically as a recovery action.

### 6. Test recoverERC20 with Non-Standard Token
1. Ensure the deployer account (`0x5B38...`) is selected.
2. Call `recoverNonStandardToken(500000000000000000000)` (500 * 10^18).
3. Check the logs in the **Terminal**:
   - Expected: No events emitted.
4. Verify balances:
   - Call `getNonStandardTokenBalance(address(platform))`: Should return `0`.
   - Call `getNonStandardTokenBalance(0x5B38...)`: Should increase by 500 * 10^18.
5. Analysis: The recovery occurred, but no on-chain trace exists, proving the missing events vulnerability.

## Testing on Sepolia Testnet
To test on the Sepolia Testnet with the deployed contract at `0x9337cf57f637f0e9150481f8d2342d090dfefa42`:
1. Deploy `StandardToken` and `NonStandardToken` on Sepolia using Remix.
2. Send 500 * 10^18 tokens of each to `0x9337cf57...`.
3. Load the `Platformofmemecoins` contract in Remix at `0x9337cf57...`.
4. Call `recoverERC20` with the addresses of `StandardToken` and `NonStandardToken` (amount: 500 * 10^18).
5. Check logs on [Sepolia Etherscan](https://sepolia.etherscan.io/):
   - `StandardToken`: `Transfer` event present.
   - `NonStandardToken`: No events.

## Vulnerability
- **Description**: The `recoverERC20` function transfers tokens without emitting an event, relying on the external token's `Transfer` event (if any).
- **Impact**: Lack of transparency, especially with non-standard tokens, as recovery operations are not logged by the contract itself.
- **Mitigation**: Add an event like `event TokensRecovered(address indexed token, address indexed to, uint256 amount)` and emit it in `recoverERC20`.

## License
This PoC is provided under the Unlicensed SPDX identifier, matching the original contract.
