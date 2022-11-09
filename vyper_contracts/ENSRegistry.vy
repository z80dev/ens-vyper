struct Record:
    owner: address
    resolver: address
    ttl: uint64

records: HashMap[bytes32, Record]
operators: HashMap[address, HashMap[address, bool]]

event NewOwner:
    node: indexed(bytes32)
    label: indexed(bytes32)
    owner: address

event Transfer:
    node: indexed(bytes32)
    owner: address

event NewResolver:
    node: indexed(bytes32)
    resolver: address

event NewTTL:
    node: indexed(bytes32)
    ttl: uint64

event ApprovalForAll:
    owner: indexed(address)
    operator: indexed(address)
    approved: bool

@external
def __init__():
    self.records[empty(bytes32)].owner = msg.sender

@external
def setRecord(node: bytes32, owner: address, resolver: address, ttl: uint64):
    self._checkAuth(node)
    self._setOwner(node, owner)
    log Transfer(node, owner)
    self.setResolverAndTTL(node, resolver, ttl)

@external
def setSubnodeRecord(node: bytes32, label: bytes32, owner: address, resolver: address, ttl: uint64):
    self._checkAuth(node)
    subnode: bytes32 = self._setSubnodeOwner(node, label, owner)
    self.setResolverAndTTL(subnode, resolver, ttl)

@external
def setOwner(node: bytes32, owner: address):
    self._checkAuth(node)
    self._setOwner(node, owner)
    log Transfer(node, owner)

@external
def setSubnodeOwner(node: bytes32, label: bytes32, owner: address):
    self._checkAuth(node)
    self._setSubnodeOwner(node, label, owner)

@external
def setResolver(node: bytes32, resolver: address):
    self._checkAuth(node)
    log NewResolver(node, resolver)
    self.records[node].resolver = resolver

@external
def setTTL(node: bytes32, ttl: uint64):
    self._checkAuth(node)
    log NewTTL(node, ttl)
    self.records[node].ttl = ttl

@external
def setApprovalForAll(operator: address, approved: bool):
    self.operators[msg.sender][operator] = approved
    log ApprovalForAll(msg.sender, operator, approved)

@external
@view
def owner(node: bytes32) -> address:
    addr: address = self.records[node].owner
    if addr == self:
        return empty(address)
    return addr

@external
@view
def resolver(node: bytes32) -> address:
    return self.records[node].resolver

@external
@view
def ttl(node: bytes32) -> uint64:
    return self.records[node].ttl

@external
@view
def recordExists(node: bytes32) -> bool:
    return self.records[node].owner != empty(address)

@external
@view
def isApprovedForAll(owner: address, operator: address) -> bool:
    return self.operators[owner][operator]

@internal
def _setSubnodeOwner(node: bytes32, label: bytes32, owner: address) -> bytes32:
    subnode: bytes32 = keccak256(_abi_encode(node, label))
    self._setOwner(subnode, owner)
    log NewOwner(node, label, owner)
    return subnode

@internal
def _checkAuth(node: bytes32):
    owner: address = self.records[node].owner
    assert owner == msg.sender or self.operators[owner][msg.sender], "!auth"

@internal
def _setOwner(node: bytes32, owner: address):
    self.records[node].owner = owner

@internal
def _authorized(node: bytes32) -> bool:
    owner: address = self.records[node].owner
    return owner == msg.sender or self.operators[owner][msg.sender]

@internal
def setResolverAndTTL(node: bytes32, resolver: address, ttl: uint64):
    if resolver != self.records[node].resolver:
        self.records[node].resolver = resolver
        log NewResolver(node, resolver)

    if ttl != self.records[node].ttl:
        self.records[node].ttl = ttl
        log NewTTL(node, ttl)
