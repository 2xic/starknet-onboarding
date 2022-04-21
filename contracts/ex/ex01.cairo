%lang starknet

# What to do in this exercise ?
#
# Write a peudo random function

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import unsigned_div_rem, assert_lt
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.hash import hash2
from starkware.starknet.common.syscalls import (
    get_block_number,
    get_block_timestamp,
    get_caller_address,
    get_tx_info,
)

@view
func generate_random_numbers{
    pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(seed : felt) -> (random):
    # TODO
    # Return a "random" number
    # Sources of entropy you can use:
    # - the `seed` parameter
    # - the block number
    # - the block timestamp
    # - the transaction infos
    #
    # Tip: using the hash2 function may help
    let (block_number) = get_block_number()
    let (block_timestamp) = get_block_timestamp()
    let (tx_info) = get_tx_info()

    let (seed1) = hash2{hash_ptr=pedersen_ptr}(seed, block_number)
    let (seed2) = hash2{hash_ptr=pedersen_ptr}(seed1, block_timestamp)
    let (seed3) = hash2{hash_ptr=pedersen_ptr}(seed2, tx_info.max_fee)
    let (seed4) = hash2{hash_ptr=pedersen_ptr}(seed3, tx_info.version)
    let (seed5) = hash2{hash_ptr=pedersen_ptr}(seed4, tx_info.signature_len)
    let (random) = hash2{hash_ptr=pedersen_ptr}(seed5, tx_info.transaction_hash)

    return (random)
end
