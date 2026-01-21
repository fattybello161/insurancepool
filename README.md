# Insurance Pool DAO - README

##  Overview

**insurance-pool-dao** is a decentralized smart contract built on the Stacks blockchain using Clarity. It implements a community-governed insurance pool where users can purchase coverage, submit claims, and participate in DAO voting to approve or reject claims.

##  Key Features

###  Pool Management
- **Fund Pool**: Users can contribute STX to the insurance pool
- **Pool Tracking**: Real-time tracking of available funds
- **Transparent Balance**: Public read access to pool balance

###  Policy Management
- **Buy Policy**: Users purchase insurance coverage with premium payments
- **Policy Details**: Track holder, premium, coverage amount, and expiry
- **Policy Expiration**: Automatic deactivation of expired policies
- **Policy Lookup**: Query policy details by ID

###  Claim System
- **Submit Claims**: Policyholders submit claims with requested amounts
- **Validation**: Claims automatically validated against:
  - Policy active status
  - Coverage limits
  - Claim amount restrictions
- **Claim Tracking**: Full audit trail of all claims

###  DAO Voting
- **Democratic Approval**: Community members vote on claims
- **Vote Prevention**: Double-voting prevention mechanism
- **Vote Counting**: Real-time yes/no vote tallying
- **Voting Window**: Time-limited voting periods

###  Payout Management
- **Automatic Resolution**: Claims resolved after voting period ends
- **Smart Payouts**: Funds only disbursed if yes votes > no votes
- **Balance Checks**: Verification before payout execution
- **Fund Safety**: Prevents over-allocation from pool

###  Reputation System
- **Reputation Tracking**: User reputation increases with successful claims
- **Public Queries**: Check user reputation scores
- **Trust Building**: Establishes community credibility

##  Contract Functions

### Public Functions

#### Fund Pool
```clarity
(fund-pool (amount uint)) -> (response bool)
```
Contributes STX to the insurance pool.
- **Parameters**: `amount` - Amount in microSTX to contribute
- **Returns**: Success confirmation

#### Buy Policy
```clarity
(buy-policy (premium uint) (coverage uint) (duration uint)) -> (response uint)
```
Purchases an insurance policy.
- **Parameters**:
  - `premium` - Premium payment in microSTX
  - `coverage` - Maximum coverage amount in microSTX
  - `duration` - Policy duration in blocks
- **Returns**: Policy ID

#### Expire Policy
```clarity
(expire-policy (policy-id uint)) -> (response bool)
```
Marks a policy as expired/inactive.
- **Parameters**: `policy-id` - ID of policy to expire
- **Returns**: Success confirmation

#### Submit Claim
```clarity
(submit-claim (policy-id uint) (amount uint) (duration uint)) -> (response uint)
```
Submits a claim for policy coverage.
- **Parameters**:
  - `policy-id` - ID of policy claiming under
  - `amount` - Claim amount in microSTX
  - `duration` - Voting period in blocks
- **Returns**: Claim ID

#### Vote on Claim
```clarity
(vote-claim (claim-id uint) (support bool)) -> (response bool)
```
Votes to approve or reject a claim.
- **Parameters**:
  - `claim-id` - ID of claim to vote on
  - `support` - `true` for approval, `false` for rejection
- **Returns**: Success confirmation

#### Resolve Claim
```clarity
(resolve-claim (claim-id uint)) -> (response bool)
```
Resolves a claim after voting period ends.
- **Parameters**: `claim-id` - ID of claim to resolve
- **Returns**: Success confirmation

### Read-Only Functions

#### Get Policy
```clarity
(get-policy (policy-id uint)) -> (optional {...})
```
Retrieves policy details by ID.

#### Get Claim
```clarity
(get-claim (claim-id uint)) -> (optional {...})
```
Retrieves claim details by ID.

#### Get Pool Funds
```clarity
(get-pool-funds) -> uint
```
Returns current pool balance in microSTX.

#### Get Reputation
```clarity
(get-reputation (user principal)) -> uint
```
Returns user's reputation score.

##  Data Structures

### Policy Map
```
{
  holder: principal,       ;; Policy owner
  premium: uint,          ;; Premium paid
  coverage: uint,         ;; Max coverage amount
  expiry: uint,           ;; Expiration block height
  active: bool            ;; Active status
}
```

### Claim Map
```
{
  policy-id: uint,        ;; Associated policy
  claimant: principal,    ;; Person making claim
  amount: uint,           ;; Claim amount
  yes: uint,              ;; Yes votes
  no: uint,               ;; No votes
  end-block: uint,        ;; Voting end block
  resolved: bool          ;; Resolution status
}
```

### Votes Map
```
{
  claim: uint,            ;; Claim ID
  voter: principal        ;; Voter address
} -> bool                 ;; Vote cast indicator
```

### Reputation Map
```
principal -> uint         ;; User -> Reputation score
```

##  Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 200 | ERR-AUTH | Authorization failed |
| 201 | ERR-NOT-FOUND | Resource not found |
| 202 | ERR-STATE | Invalid state or validation failed |
| 203 | ERR-BALANCE | Insufficient pool balance |

##  Security Features

✅ **Double-Voting Prevention**: Voters can only vote once per claim
✅ **Balance Validation**: Checks pool balance before payouts
✅ **Coverage Limits**: Enforces maximum claim amounts
✅ **Policy Verification**: Validates policy active status
✅ **Voting Windows**: Time-limited voting periods
✅ **Input Validation**: All amounts validated as non-zero

##  Usage Example

```clarity
;; 1. User funds the pool
(fund-pool u1000000)  ;; Contributes 1 STX

;; 2. User buys a policy
(buy-policy u100000 u500000 u52560)  ;; 0.1 STX premium, 0.5 STX coverage, ~1 year

;; 3. User submits a claim
(submit-claim u1 u250000 u144)  ;; Claims 0.25 STX, 1-day voting period

;; 4. Community votes
(vote-claim u1 true)   ;; Approve claim
(vote-claim u1 false)  ;; Reject claim

;; 5. Resolve claim
(resolve-claim u1)     ;; Execute if approved
```

##  Contract Constants

- **ERR-AUTH**: u200
- **ERR-NOT-FOUND**: u201
- **ERR-STATE**: u202
- **ERR-BALANCE**: u203

##  State Variables

- `pool-funds`: Total STX in pool (uint)
- `policy-count`: Total policies created (uint)
- `claim-count`: Total claims submitted (uint)

##  Future Enhancements

- Premium adjustment based on risk profiles
- Multi-tier coverage levels
- Claim dispute resolution process
- Automated premium calculations
- Integration with price feeds for dynamic coverage

##  License

This contract is part of the Stacks ecosystem and follows the Stacks protocol guidelines.

##  Contributing

For issues, improvements, or feature requests, please submit feedback to the project repository.

---

**Contract Status**: ✅ Production Ready  
**Last Updated**: January 21, 2026  
**Network**: Stacks Mainnet / Testnet Compatible
