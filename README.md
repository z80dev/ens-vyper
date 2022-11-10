# ens-vyper

A vyper implementation of ENS core contracts

## Gas comparison

### ENSRegistry

* 304 gas saved on `setOwner` (4.2% savings)
* 245 gas saved on `setSubnodeOwner` (.09% savings)

### FIFSRegistrar

* 1113 gas saved on `register` (3.1% savings)
* 1140 gas saved on calling `register` to transfer a name that already exists (6% savings)
