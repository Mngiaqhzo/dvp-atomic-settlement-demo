# DvP Atomic Settlement Demo

This is a beginner Solidity project about **Delivery versus Payment (DvP)** atomic settlement.

I built this project to understand how two sides of a trade can be settled together on-chain:

* the asset side
* the cash side

The main idea is simple:

> The asset and the cash should either move together, or neither should move.

This demo uses simple ERC20 tokens and runs in Remix VM. It does not use real assets.

## What This Project Includes

This project has three smart contracts:

| Contract         | Purpose                                             |
| ---------------- | --------------------------------------------------- |
| `TokenizedCash`  | A simple ERC20 token used as cash                   |
| `TokenizedAsset` | A simple ERC20 token used as the asset              |
| `DvPSettlement`  | A contract that settles the asset and cash together |

All three contracts are placed in one Solidity file:

```text
contracts/DvPSettlement.sol
```

## Why I Built This

In a normal trade, there are usually two steps:

1. The seller sends the asset to the buyer.
2. The buyer sends cash to the seller.

If one side happens but the other side fails, there is settlement risk.

For example:

* the seller sends the asset but does not receive cash
* the buyer pays cash but does not receive the asset

DvP means **Delivery versus Payment**. It tries to make sure that both sides happen together.

I used this project to learn how a smart contract can help model this idea.

## How It Works

The settlement contract stores a trade with:

* seller address
* buyer address
* asset token address
* asset amount
* cash token address
* cash amount

Before settlement:

1. The seller approves the DvP contract to transfer the asset.
2. The buyer approves the DvP contract to transfer the cash.
3. The seller creates a trade.
4. The settlement function is called.

The important function is `settle()`.

Inside this function:

1. The asset is transferred from the seller to the buyer.
2. The cash is transferred from the buyer to the seller.

Both transfers happen in one blockchain transaction.

If the cash transfer fails, the whole transaction reverts. This also cancels the asset transfer.

## Example Trade

In my demo, I used this example:

```text
Seller gives: 10 tBOND
Buyer pays:  1000 tHKD
```

The seller owns the asset token.

The buyer receives some cash token before the trade starts.

## Successful Settlement Demo

In the successful test:

1. The seller approved `10 tBOND`.
2. The buyer approved `1000 tHKD`.
3. A trade was created.
4. The `settle()` function was called.
5. The asset and cash balances both changed.

Expected result:

```text
Buyer receives 10 tBOND
Seller receives 1000 tHKD
```

This shows that the asset and cash were settled together.

Screenshot:

```text
screenshots/01-successful-settlement.png
```

## Failed Settlement Demo

I also tested a failed case.

In this test:

1. The seller approved enough asset.
2. The buyer only approved `500 tHKD`.
3. The trade still required `1000 tHKD`.
4. The `settle()` function was called.
5. The transaction failed.

The payment side failed because the buyer did not approve enough cash.

The key result is:

```text
The asset balances did not change.
```

This means the asset was not transferred when the payment failed.

Even though the contract tries to transfer the asset first, the whole transaction is reverted when the payment transfer fails.

This helped me understand what atomic settlement means.

Screenshots:

```text
screenshots/02-failed-settlement-error.png
screenshots/03-balances-unchanged-after-revert.png
```

## What I Learned

Through this project, I learned:

* how to deploy simple ERC20 tokens in Remix
* how `approve()` works
* how `transferFrom()` works
* why both the buyer and seller need to approve the settlement contract
* how a smart contract can connect two token transfers
* what transaction revert means
* why testing a failed case is important
* how DvP can be explained with a simple on-chain example

## Project Structure

```text
dvp-atomic-settlement-demo/
├── README.md
├── contracts/
│   └── DvPSettlement.sol
└── screenshots/
    ├── 01-successful-settlement.png
    ├── 02-failed-settlement-error.png
    └── 03-balances-unchanged-after-revert.png
```

## How to Run This Project

1. Open Remix IDE.
2. Create a new file called `DvPSettlement.sol`.
3. Paste the Solidity code from `contracts/DvPSettlement.sol`.
4. Compile the contract with Solidity version `0.8.20` or above.
5. Deploy these three contracts in Remix VM:

   * `TokenizedCash`
   * `TokenizedAsset`
   * `DvPSettlement`
6. Use two Remix accounts:

   * Account 1 as the seller
   * Account 2 as the buyer
7. Transfer some cash token to the buyer.
8. Approve the DvP contract from both accounts.
9. Create a trade.
10. Call `settle()`.

## Files in This Repository

### `contracts/DvPSettlement.sol`

This file contains:

* `TokenizedCash`
* `TokenizedAsset`
* `DvPSettlement`

### `screenshots/`

This folder contains screenshots from Remix showing:

* successful settlement
* failed settlement
* unchanged balances after revert

