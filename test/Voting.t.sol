// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Voting.sol";

contract VotingTest is Test {
    Voting public voting;

    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);

    string[] public initialCandidates;

    function setUp() public {
        initialCandidates.push("Alice");
        initialCandidates.push("Bob");
        initialCandidates.push("Charlie");

        voting = new Voting(initialCandidates);
    }

    function test_InitialCandidateSetup() public view {
        assertEq(voting.getCandidateCount(), 3);

        (string memory name0, uint256 votes0) = voting.candidates(0);
        assertEq(name0, "Alice");
        assertEq(votes0, 0);

        (string memory name1, uint256 votes1) = voting.candidates(1);
        assertEq(name1, "Bob");
        assertEq(votes1, 0);

        (string memory name2, uint256 votes2) = voting.candidates(2);
        assertEq(name2, "Charlie");
        assertEq(votes2, 0);
    }

    function test_VoteSuccessfully() public {
        vm.prank(alice);
        voting.vote(1);

        assertTrue(voting.hasVoted(alice));
        (, uint256 votes) = voting.candidates(1);
        assertEq(votes, 1);
    }

    function test_RevertWhen_VotingTwice() public {
        vm.startPrank(alice);
        voting.vote(0);

        vm.expectRevert("Already voted");
        voting.vote(1);
        vm.stopPrank();
    }

    function test_RevertWhen_CandidateIndexOutOfBounds() public {
        vm.prank(alice);
        vm.expectRevert("Invalid candidate");
        voting.vote(99);
    }

    function test_GetWinner() public {
        vm.prank(alice);
        voting.vote(1); // Bob gets 1 vote

        vm.prank(bob);
        voting.vote(1); // Bob gets 2nd vote

        vm.prank(charlie);
        voting.vote(0); // Alice gets 1 vote

        string memory winner = voting.getWinner();
        assertEq(winner, "Bob");
    }

    function test_GetWinner_DefaultsToFirstOnTie() public {
        vm.prank(alice);
        voting.vote(0); // Alice: 1

        vm.prank(bob);
        voting.vote(1); // Bob: 1

        // Strict inequality (>), so candidate 0 remains winner on tie
        string memory winner = voting.getWinner();
        assertEq(winner, "Alice");
    }

    function test_RevertWhen_GetWinnerWithNoCandidates() public {
        string[] memory emptyCandidates;
        Voting emptyVoting = new Voting(emptyCandidates);

        vm.expectRevert("No candidates");
        emptyVoting.getWinner();
    }
}