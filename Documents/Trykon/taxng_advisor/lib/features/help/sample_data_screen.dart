import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SampleDataScreen extends StatefulWidget {
  const SampleDataScreen({super.key});

  @override
  State<SampleDataScreen> createState() => _SampleDataScreenState();
}

class _SampleDataScreenState extends State<SampleDataScreen> {
  static const _jsonSamples = {
    'CIT': '''{
  "type": "CIT",
  "year": 2024,
  "data": {
    "turnover": 50000000,
    "expenses": 15000000,
    "profit": 35000000,
    "businessName": "Acme LLC",
    "tin": "12345678901"
  }
}''',
    'VAT': '''{
  "type": "VAT",
  "year": 2024,
  "period": "Q4",
  "data": {
    "totalSales": 5000000,
    "taxableSales": 4500000,
    "exemptSales": 500000,
    "inputTax": 675000,
    "outputTax": 675000,
    "vat": 0
  }
}''',
    'PIT': '''{
  "type": "PIT",
  "year": 2024,
  "data": {
    "employeeId": "EMP001",
    "employeeName": "John Doe",
    "grossIncome": 3600000,
    "taxableIncome": 3000000,
    "personalRelief": 200000,
    "standardRelief": 300000,
    "pit": 600000
  }
}''',
    'WHT': '''{
  "type": "WHT",
  "year": 2024,
  "data": {
    "paymentDescription": "Service provision",
    "grossAmount": 1000000,
    "whtRate": 0.05,
    "whtAmount": 50000,
    "beneficiary": "John Services Ltd",
    "tin": "87654321098"
  }
}''',
    'Payroll': '''{
  "type": "Payroll",
  "year": 2024,
  "month": "December",
  "data": {
    "employeeCount": 25,
    "totalGrossSalary": 10000000,
    "totalDeductions": 2500000,
    "totalPIT": 1500000,
    "totalNHF": 250000,
    "totalPENSION": 750000,
    "netPayroll": 7500000
  }
}''',
    'Stamp Duty': '''{
  "type": "StampDuty",
  "year": 2024,
  "data": {
    "transactionType": "Property Sale",
    "propertyAddress": "123 Lekki Lane, Lagos",
    "transactionValue": 50000000,
    "stampDutyRate": 0.015,
    "stampDutyAmount": 750000,
    "buyer": "Jane Smith",
    "seller": "Property Holdings Ltd"
  }
}''',
  };

  static const _csvSamples = {
    'CIT': 'type,year,turnover,expenses,profit,businessName,tin\n'
        'CIT,2024,50000000,15000000,35000000,Acme LLC,12345678901\n'
        'CIT,2024,75000000,20000000,55000000,TechStart Ltd,98765432101',
    'VAT':
        'type,year,period,totalSales,taxableSales,exemptSales,inputTax,outputTax,vat\n'
            'VAT,2024,Q4,5000000,4500000,500000,675000,675000,0\n'
            'VAT,2024,Q3,3500000,3200000,300000,480000,480000,0',
    'PIT':
        'type,year,employeeId,employeeName,grossIncome,taxableIncome,personalRelief,standardRelief,pit\n'
            'PIT,2024,EMP001,John Doe,3600000,3000000,200000,300000,600000\n'
            'PIT,2024,EMP002,Jane Smith,2400000,2100000,200000,300000,360000',
    'WHT': 'type,year,paymentDescription,grossAmount,whtRate,whtAmount,beneficiary,tin\n'
        'WHT,2024,Service provision,1000000,0.05,50000,John Services Ltd,87654321098\n'
        'WHT,2024,Contract payment,500000,0.05,25000,Consulting Ltd,11223344556',
    'Payroll': 'type,year,month,employeeCount,totalGrossSalary,totalDeductions,totalPIT,totalNHF,totalPENSION,netPayroll\n'
        'Payroll,2024,December,25,10000000,2500000,1500000,250000,750000,7500000\n'
        'Payroll,2024,November,25,10000000,2500000,1500000,250000,750000,7500000',
    'Stamp Duty':
        'type,year,transactionType,propertyAddress,transactionValue,stampDutyRate,stampDutyAmount,buyer,seller\n'
            'StampDuty,2024,Property Sale,123 Lekki Lane Lagos,50000000,0.015,750000,Jane Smith,Property Holdings Ltd\n'
            'StampDuty,2024,Property Sale,456 VI Road Lagos,75000000,0.015,1125000,Ahmed Corp,Estate Investments LLC',
  };

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sample Data'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'JSON Format'),
              Tab(text: 'CSV Format'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // JSON Tab
            _buildSampleTab(_jsonSamples, 'JSON', true),
            // CSV Tab
            _buildSampleTab(_csvSamples, 'CSV', false),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleTab(
      Map<String, String> samples, String format, bool isJson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions Card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'How to Use $format',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isJson
                        ? '1. Select a tax type below\n'
                            '2. Expand and view the example JSON\n'
                            '3. Click "Copy" to copy to clipboard\n'
                            '4. Go to Profile → Import Data\n'
                            '5. Paste the JSON and click Import\n'
                            '6. The calculator opens with sample data'
                        : '1. Select a tax type below\n'
                            '2. Expand and view the example CSV\n'
                            '3. Click "Copy" to copy to clipboard\n'
                            '4. Go to Profile → Import Data\n'
                            '5. Paste the CSV and click Import\n'
                            '6. The calculator opens with first row data',
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isJson
                        ? 'Tip: Edit JSON values before importing to match your data.'
                        : 'Tip: Each row (after headers) is one record. Download sample CSV from assets/help/',
                    style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sample Data Templates - $format',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...samples.entries.map((e) {
            return _SampleCard(
              title: e.key,
              data: e.value,
              isJson: isJson,
              onCopy: () => _copyToClipboard(e.value),
            );
          }),
        ],
      ),
    );
  }
}

class _SampleCard extends StatefulWidget {
  final String title;
  final String data;
  final bool isJson;
  final VoidCallback onCopy;

  const _SampleCard({
    required this.title,
    required this.data,
    required this.isJson,
    required this.onCopy,
  });

  @override
  State<_SampleCard> createState() => _SampleCardState();
}

class _SampleCardState extends State<_SampleCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onExpansionChanged: (expanded) => setState(() {}),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      widget.data,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: widget.onCopy,
                  icon: const Icon(Icons.content_copy),
                  label: Text('Copy ${widget.isJson ? 'JSON' : 'CSV'}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
