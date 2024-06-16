import 'package:flutter/material.dart';
import 'LoginRateDetails.dart';

class LoginRateSelection extends StatelessWidget {
  const LoginRateSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4131),
        title: const Text('Select Time Period', style: TextStyle(color: Color(0xFF000000))),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToDetails(context, 'daily'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4131)),
              child: const Text('Daily Login Rate', style: TextStyle(color: Color(0xFF000000))),
            ),
            ElevatedButton(
              onPressed: () => _navigateToDetails(context, 'monthly'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4131)),
              child: const Text('Monthly Login Rate', style: TextStyle(color: Color(0xFF000000))),
            ),
            ElevatedButton(
              onPressed: () => _navigateToDetails(context, 'yearly'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4131)),
              child: const Text('Yearly Login Rate', style: TextStyle(color: Color(0xFF000000))),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, String period) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Date for $period Login Rate', style: const TextStyle(color: Color(0xFF000000))),
          content: DateInputForm(period: period),
        );
      },
    );
  }
}

class DateInputForm extends StatefulWidget {
  final String period;
  const DateInputForm({required this.period});

  @override
  _DateInputFormState createState() => _DateInputFormState();
}

class _DateInputFormState extends State<DateInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.period == 'daily') ...[
            TextFormField(
              controller: _dayController,
              decoration: InputDecoration(labelText: 'Day', labelStyle: const TextStyle(color: Color(0xFF000000))),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a day';
                }
                return null;
              },
            ),
          ],
          if (widget.period != 'yearly') ...[
            TextFormField(
              controller: _monthController,
              decoration: InputDecoration(labelText: 'Month', labelStyle: const TextStyle(color: Color(0xFF000000))),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a month';
                }
                return null;
              },
            ),
          ],
          TextFormField(
            controller: _yearController,
            decoration: InputDecoration(labelText: 'Year', labelStyle: const TextStyle(color: Color(0xFF000000))),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a year';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final day =
                    widget.period == 'daily' ? _dayController.text : null;
                final month =
                    widget.period != 'yearly' ? _monthController.text : null;
                final year = _yearController.text;
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginRateDetails(
                      period: widget.period,
                      day: day,
                      month: month,
                      year: year,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4131)),
            child: const Text('Submit', style: TextStyle(color: Color(0xFF000000))),
          ),
        ],
      ),
    );
  }
}
