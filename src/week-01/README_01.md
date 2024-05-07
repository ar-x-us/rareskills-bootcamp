## What problems ERC777 and ERC1363 solves?

- ERC777 and ERC1363 implement new ways to interact via "hooks" with token contracts while maintaining backwards compatibility with ERC20 for the purpose of reducing multiple transactions resulting in higher gas fees.
- The hooks allow for reactive behavior by triggering callback functions when tokens are sent / received.
- In ERC20 alone, the tokens are sent, there is no mechanism to identify who sent the tokens. However, there is a workaround is to implement more complex logic that requires multiple transaction resulting in double the costs of the overall implementation. The multiple transactions involve `approve` and `transferFrom`; however, when using these there are other problems such as potential race-conditions using `approve` [link](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM) that need to be accounted for.

## Why was ERC1363 introduced, and what issues are there with ERC777?

- ERC1363 was introduced to do what ERC777 was intended to do without the complexity and security issues (see below) while keeping gas costs low.
- The issue with ERC777 is that it has been known to be more complex to setup requiring a registry (ERC1820) to register hooks leading to higher gas costs. Also when not properly configured could lead to reentrancy attacks.
- ERC777 opened up a door allowing older contracts that did not take into account `transfer` and `transferFrom` functions calling external contracts were vulnerable to reentrency attacks. ERC1363 let ERC20 completely handle `transfer` and `transferFrom` to resolve this problem and introduced additional methods to enhance the protocol related to sending and transfering tokens.
- As a result complex setup and higher probability of attacks of ERC777, it has been deprecated by OpenZeppelin since version 4.9.