import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Counter increments smoke test', () {
    int counter = 0;

    // Verify that our counter starts at 0.
    expect(counter, 0);

    // Increment the counter.
    counter++;

    // Verify that our counter has incremented.
    expect(counter, 1);
  });
}
