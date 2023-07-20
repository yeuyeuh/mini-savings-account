
# Mini Savings Account

## Guidelines

Your mission is to develop the smart-contracts for a mini Web3 savings account
infrastructure.

MiniSavingsAccount allows users to create and manage savings accounts. Users can
deposit funds into their accounts, withdraw funds when needed, and earn interest on
their savings. The system should support multiple tokens, such as USD, EUR, and GBP,
and should be designed to accommodate new tokens in the future.

Feel free to make assumptions, but please add comments or assertions describing the
assumptions you are making.

You should create one or multiple smart-contracts that implement your version of
MiniSavingsAccount.

It should be written in Solidity and utilize the Foundry framework. It should be an
independent repository, complete with a README, tests, comments, and any other
documentation expected in high-quality software engineering.

Please share a link to the repository when you’re finished. We advise you to try to show
how much you can demonstrate your value in a limited time instead of trying to make
something perfect. Be creative and showcase a variety of skills.

Feel free to ask as many questions as you need to carry on with the task. The task is
intentionally ambiguous to inspire innovation.

Please provide your updated implementation and repository link when you're ready.

## Assumptions

* <em><strong> "User can [...] earn interest on their savings." </strong></em> 
&rarr; We create a specific token linked to this protocol which is called MSA (MsaToken). Users will earn MSA based on their savings. The APR is 5% and is updated every seconds.

* <em><strong> "The system should support multiple tokens, such as USD, EUR, and GBP" </strong></em>
&rarr; The system will only accept stable token which are pegged to a specific asset. Depending on the stablecoin they deposit in the protocol, they will earn MSA based on `peggedAssetExchangeRate` which is the exchange ratio of the pegged asset of this stablecoin regarding USD (for EUR, `peggedAssetExchangeRate`=1.12). 
For example, if Alice deposits 1000 EURt (stablecoin pegged to EUR), after one year she will earn 1000 x `peggedAssetExchangeRate` x APR = 1000 x 1.12 x 0.05 = 56 MSA.
If Bill deposits 1000 USDt (stablecoin pegged to USD), after one year he will earn 1000 x `peggedAssetExchangeRate` x APR = 1000 x 1 x 0.05 = 50 MSA.

* <em><strong> "The system [...] should be designed to accommodate new tokens in the future." </strong></em>
&rarr;  The owner of the contract can accept new tokens  in the protocol and he can change the `peggedAssetExchangeRate`.

## Improvements :
* reentrency attack
* ability to remove some stabletoken
* DAO (instead of owner) to vote for futur stabletoken, to vote for exchangerate (or oracle)
* BigNumber
* decimals (if some stablecoins have decimals other from 18)

## How to test

```sh
forge test
```