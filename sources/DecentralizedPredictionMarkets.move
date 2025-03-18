module MyModule::PredictionMarket {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a prediction market for a real-world event.
    struct Market has store, key {
        event_name: vector<u8>,    // Name of the event
        outcome_1: u64,            // Bet amount for outcome 1
        outcome_2: u64,            // Bet amount for outcome 2
        total_bets: u64,           // Total bets placed on the market
    }

    /// Function to create a new prediction market for an event.
    public fun create_market(owner: &signer, event_name: vector<u8>) {
        let market = Market {
            event_name,
            outcome_1: 0,
            outcome_2: 0,
            total_bets: 0,
        };
        move_to(owner, market);
    }

    /// Function for users to place bets on a prediction market's outcome.
    public fun place_bet(bettor: &signer, market_owner: address, outcome: u8, amount: u64) acquires Market {
        let market = borrow_global_mut<Market>(market_owner);

        // Ensure valid outcome (either 1 or 2)
        assert!(outcome == 1 || outcome == 2, 100);  // Error code 100 for invalid outcome

        // Withdraw the bet amount from the bettor
        let bet = coin::withdraw<AptosCoin>(bettor, amount);
        coin::deposit<AptosCoin>(market_owner, bet);

        // Update the bet amounts for the selected outcome
        if (outcome == 1) {
            market.outcome_1 = market.outcome_1 + amount;
        } else {
            market.outcome_2 = market.outcome_2 + amount;
        }

        // Update total bets placed on the market
        market.total_bets = market.total_bets + amount;
    }
}
