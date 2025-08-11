# UTXOracle-RPC

Enhanced version of UTXOracle using Bitcoin RPC calls for universal compatibility.

## 🚀 Key Improvements

- **🔧 RPC-based**: Uses `bitcoin-cli` instead of direct file reading
- **⚡ Bitcoin Knots Compatible**: Works with both Bitcoin Core and Bitcoin Knots
- **📊 Block Range Search**: Analyze specific block ranges *(coming soon)*
- **⏰ Optimized Cron**: `--no-html` flag for automated runs
- **🛠️ Monitoring Ready**: Includes Nagios/RRD integration script

## 📖 About UTXOracle

UTXOracle is a decentralized alternative for establishing the USD price of Bitcoin. Instead of relying on exchange prices, UTXOracle determines the price by analyzing patterns of on-chain transactions. It connects only to a Bitcoin node with no external API dependencies.

### Why This Fork?

The original UTXOracle reads Bitcoin block files directly from disk, which doesn't work reliably with Bitcoin Knots due to different file structures. This RPC version uses `bitcoin-cli` calls, making it universally compatible with any Bitcoin implementation that supports standard RPC calls.

## 🛠️ Requirements

- Python 3.6+
- Bitcoin node (Core or Knots) with RPC enabled
- `bitcoin-cli` accessible in PATH or current directory

## ⚙️ Installation

1. Clone this repository:
```bash
git clone https://github.com/g1llez/UTXOracle-RPC.git
cd UTXOracle-RPC
```

2. Ensure your `bitcoin.conf` has:
```
server=1
rpcuser=your_username
rpcpassword=your_password
```

3. Make sure `bitcoin-cli` is available:
```bash
# Copy bitcoin-cli to the project directory, or ensure it's in your PATH
cp /path/to/bitcoin-cli .
```

## 🎯 Usage

### Basic Usage
```bash
# Get price for a specific date
python3 UTXOracle.py -d 2025/08/10

# Get price from recent 144 blocks
python3 UTXOracle.py -rb

# Run without HTML generation (for automation)
python3 UTXOracle.py -rb --no-html
```

### Automated Monitoring
```bash
# Run the cron script (already includes --no-html)
./UTXOracle_cron.sh
```

The cron script saves price data to `/var/cache/utxoracle/last_price.txt` in this format:
```
date: 2025-08-10
price: 118143
timestamp: 2025-08-10T23:07:05Z
```

## 📊 Monitoring Integration

The included `utxoracle_nagios_rrd.sh` script provides:
- Nagios/Icinga monitoring integration
- RRD database creation and updates
- Performance data logging

## 🔧 Configuration

### Bitcoin Node Setup
Ensure your Bitcoin node is properly configured and synchronized. The script will automatically detect RPC credentials from `bitcoin.conf`.

### Cron Setup
To run UTXOracle automatically every hour:
```bash
# Add to crontab
0 * * * * /home/user/UTXOracle-RPC/UTXOracle_cron.sh
```

## 📈 How It Works

1. **Block Analysis**: Analyzes all transactions from Bitcoin blocks
2. **Transaction Filtering**: Applies strict filters to identify likely USD-denominated transactions
3. **Pattern Recognition**: Uses statistical analysis to find round USD amounts
4. **Price Estimation**: Calculates the most likely USD price based on transaction patterns

## 🔍 Upcoming Features

- **Block Range Search**: Specify custom block ranges with `-br START END`
- **Enhanced Monitoring**: Additional metrics and alerts
- **Performance Improvements**: Optimized RPC calls

## 📝 License

This project maintains the same custom license as the original UTXOracle. See the license section in `UTXOracle.py` for full details.

## 🙏 Credits

Based on the original UTXOracle by [@SteveSimple](https://twitter.com/SteveSimple). This fork focuses on RPC compatibility and enhanced automation features.

## 🐛 Issues & Contributing

Please report issues or contribute improvements via GitHub issues and pull requests.

---

**⚠️ Disclaimer**: UTXOracle provides price estimates for educational and analytical purposes. Not financial advice.
