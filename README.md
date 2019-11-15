# Aurei contracts

### Setup

You may have `truffle` and `ganache-cli` installed globally

```
$ npm install -g truffle
$ npm install -g ganache-cli
```

or use a pre-configured environment like the [eth-security-toolbox](https://hub.docker.com/r/trailofbits/eth-security-toolbox) by Trail of Bits.

Install dependencies.

```
$ npm install
```

### Compile

To re-compile contracts and build artifacts:

```
$ truffle compile
```

### Deploy to local ganache-cli

To deploy contracts to a local Ganche RPC provider at port `8545`:

```
$ ganache-cli -l 8000000
$ truffle deploy
```


### Unit Tests

To execute the full unit test truffle suite: 

```
$ truffle test
```
