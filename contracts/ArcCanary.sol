// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ArcCanary
 * @notice Developer health canary & on-chain benchmark contract for Arc Mainnet.
 * @dev Deployed on Arc Mainnet (Chain ID 5042). On Arc, native gas is USDC (18 decimals).
 */
contract ArcCanary {
    struct Heartbeat {
        address sender;
        uint256 blockNumber;
        uint256 timestamp;
        uint256 gasPrice;
        string clientTag;
        bytes32 payloadHash;
    }

    uint256 public totalHeartbeats;
    Heartbeat public latestHeartbeat;
    mapping(address => uint256) public heartbeatCounts;

    event HeartbeatRecorded(
        address indexed sender,
        uint256 indexed blockNumber,
        uint256 timestamp,
        string clientTag,
        uint256 gasConsumed
    );

    function recordHeartbeat(string calldata clientTag) external payable returns (uint256) {
        uint256 gasStart = gasleft();
        totalHeartbeats++;
        heartbeatCounts[msg.sender]++;

        latestHeartbeat = Heartbeat({
            sender: msg.sender,
            blockNumber: block.number,
            timestamp: block.timestamp,
            gasPrice: tx.gasprice,
            clientTag: clientTag,
            payloadHash: keccak256(abi.encodePacked(msg.sender, block.number, block.timestamp))
        });

        uint256 gasConsumed = gasStart - gasleft() + 21000;
        emit HeartbeatRecorded(msg.sender, block.number, block.timestamp, clientTag, gasConsumed);
        return totalHeartbeats;
    }

    function getDiagnostics() external view returns (
        uint256 totalPings,
        uint256 currentBlock,
        uint256 currentTimestamp,
        address lastSender,
        string memory lastTag
    ) {
        return (
            totalHeartbeats,
            block.number,
            block.timestamp,
            latestHeartbeat.sender,
            latestHeartbeat.clientTag
        );
    }
}
