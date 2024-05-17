use super::errors::SubmitNewGuardianSetError;
use pyth::byte_array::ByteArray;
use core::starknet::secp256_trait::Signature;

#[starknet::interface]
pub trait IWormhole<T> {
    fn parse_and_verify_vm(self: @T, encoded_vm: ByteArray) -> VerifiedVM;
    fn chain_id(self: @T) -> u16;

    // We don't need to implement other governance actions for now.
    // Instead of upgrading the Wormhole contract, we can switch to another Wormhole address
    // in the Pyth contract.
    fn submit_new_guardian_set(ref self: T, encoded_vm: ByteArray);
}

#[derive(Drop, Debug, Clone, Serde)]
pub struct GuardianSignature {
    pub guardian_index: u8,
    pub signature: Signature,
}

#[derive(Drop, Debug, Clone, Serde)]
pub struct VerifiedVM {
    pub version: u8,
    pub guardian_set_index: u32,
    pub signatures: Array<GuardianSignature>,
    pub timestamp: u32,
    pub nonce: u32,
    pub emitter_chain_id: u16,
    pub emitter_address: u256,
    pub sequence: u64,
    pub consistency_level: u8,
    pub payload: ByteArray,
    pub hash: u256,
}

/// Returns the number of signatures required to verify a message.
pub fn quorum(num_guardians: usize) -> usize {
    assert(num_guardians < 256, SubmitNewGuardianSetError::TooManyGuardians.into());
    ((num_guardians * 2) / 3) + 1
}
