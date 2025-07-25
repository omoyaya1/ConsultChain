# ConsultChain

A decentralized professional consulting project tracking and recognition platform for incentivizing business expertise sharing on Stacks blockchain.

## Features

- Consulting hour tracking with industry-based validation
- Professional consultant recognition and reward system
- Industry approval and management system
- Contribution-based recognition point calculation
- Comprehensive consulting program statistics

## Smart Contract Functions

### Public Functions
- `launch-consulting-program` - Initialize consulting tracking program
- `approve-industry` - Approve industry for tracking (coordinator only)
- `log-consulting-hours` - Register consulting hours with industry
- `calculate-recognition-points` - Calculate recognition points (coordinator only)
- `claim-consulting-recognition` - Claim consulting recognition rewards

### Read-Only Functions
- `get-consulting-hours` - Get consultant's total hours
- `get-consultant-industry` - Get consultant's industry specialization
- `get-total-consulting-hours` - Get total program hours
- `is-industry-approved` - Check industry approval status
- `get-program-stats` - Get comprehensive program statistics

## Industries
Technology, Finance, Healthcare, Manufacturing, Retail, Energy, etc.

## Usage

Deploy the contract to create a consulting tracking system where professional consultants can log project hours, earn recognition, and contribute to business expertise sharing initiatives.

## License

MIT