//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";

contract PrivacyPool is Ownable {
  using SafeERC20 for IERC20;

  ISemaphore public semaContract;
  uint256 public groupId;
  IERC20 public token;
  uint256 public denomination;
  address public committeeKey;

  mapping(uint256 => bool) internal deposits;
  mapping(uint256 => bool) internal usedNullifierHashes;

  event Deposit(uint256 identityCommitment);
  event WithdrawPrivate(bytes32 signal, uint256 nullifierHash);
  event WithdrawPublic(uint256 identityCommitment, uint256 nullifierHash);

  constructor(
    ISemaphore semaContractAddr,
    uint256 newGroupId,
    IERC20 tokenContractAddr,
    uint256 tokenAmount,
    address committeeKeyAddr
  ) Ownable() {
    semaContract = semaContractAddr;
    groupId = newGroupId;
    token = tokenContractAddr;
    denomination = tokenAmount;
    committeeKey = committeeKeyAddr;

    semaContract.createGroup(groupId, 32, 0, address(this));
  }

  /*
    Any account may freely deposit into the pool
  */
  function deposit(uint256 identityCommitment) external {
    require(!deposits[identityCommitment]);

    semaContract.addMember(groupId, identityCommitment);

    deposits[identityCommitment] = true;

    emit Deposit(identityCommitment);

    token.safeTransferFrom(msg.sender, address(this), denomination);
  }

  /*
    In the possibility that the verification server does not allow
    withdraw private, (due to failure or security compromise)
    allow a public withdraw that links to the deposit without
    requiring verification from the server that there is a matching
    identity commitment. (i.e. No way for central authority to hold
    funds hostage)
  */
  function withdrawPublic(
    uint256 nullifier,
    uint256 trapdoor,
    // TODO instead of accepting the nullifierHash from the client,
    //   generate the full proof and nullifierHash in Solidity,
    //   in order to ensure the client is not sending false data
    uint256 nullifierHash
  ) external {
    uint256 identityCommitment = generateCommitment(nullifier, trapdoor);
    require(deposits[identityCommitment]);
    require(!usedNullifierHashes[nullifierHash]);
    emit WithdrawPublic(identityCommitment, nullifierHash);
    token.safeTransfer(msg.sender, denomination);
  }

  function generateCommitment(
    uint256 nullifier,
    uint256 trapdoor
  ) internal view returns(uint256) {
    // TODO!
    return 0;
  }

  /*
    Before performing a private withdrawal, publish a hash of the
    withdrawal data so that in the case of the server acting
    maliciously, the contract will only allow the withdrawal to
    transfer to this address
  */
  function withdrawPrivatePlan(
    bytes32 hash
  ) external {
  }

  /*
    Perform the private withdrawal with the approval of the server
    that the proof matches an encrypted identity commitment
  */
  function withdrawPrivate(
    bytes memory serverSignature,
    uint256 merkleTreeRoot,
    bytes32 signal,
    uint256 nullifierHash,
    uint256 externalNullifier,
    uint256[8] calldata proof
  ) external {
    require(!usedNullifierHashes[nullifierHash]);
    usedNullifierHashes[nullifierHash] = true;
    semaContract.verifyProof(groupId, merkleTreeRoot, signal, nullifierHash, externalNullifier, proof);

    // Verify signature from the server
    bytes32 hash = keccak256(abi.encode(merkleTreeRoot, signal, nullifierHash, externalNullifier, proof));
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(serverSignature);
    bytes32 ethSignedHash = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));

    address sigAddr = ecrecover(ethSignedHash, v, r, s);
    require(sigAddr == committeeKey, "Invalid Signature");

    emit WithdrawPrivate(signal, nullifierHash);

    token.safeTransfer(msg.sender, denomination);
  }

  // From https://solidity-by-example.org/signature/
  function splitSignature(bytes memory sig) internal pure
    returns (bytes32 r, bytes32 s, uint8 v)
  {
    require(sig.length == 65, "invalid signature length");
    assembly {
        // first 32 bytes, after the length prefix
        r := mload(add(sig, 32))
        // second 32 bytes
        s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
        v := byte(0, mload(add(sig, 96)))
    }
  }
}
