import 'dart:math';

void main() {
  String message = '111010011100';
  List<int> key = [1, 0, 0, 1];
  List<int> seed = [0, 0, 1, 0];
  key.insert(0, 1);

  SynchronousStreamCipher encryptionCipher = SynchronousStreamCipher(key, seed);
  SynchronousStreamCipher decryptionCipher = SynchronousStreamCipher(key, seed);

  String encryptedMessage = encryptionCipher.encrypt(message);
  String decryptedMessage = decryptionCipher.encrypt(encryptedMessage);

  print('Original: $message');
  print('Encrypted: $encryptedMessage');
  print('Decrypted: $decryptedMessage');
}

class SynchronousStreamCipher {
  late LinearFeedbackShiftRegister encryptionRegister;

  SynchronousStreamCipher(List<int> coefficients, List<int> seed) {
    encryptionRegister = LinearFeedbackShiftRegister(coefficients, seed);
  }

  String encrypt(String message) {
    return String.fromCharCodes(message.runes.map((charCode) {
      int bit = charCode == 49 ? 1 : 0;
      int encryptedBit = bit ^ encryptionRegister.getNext();
      return encryptedBit == 1 ? 49 : 48;
    }));
  }
}

class LinearFeedbackShiftRegister {
  late List<int> register;
  late List<int> seed;
  late List<int> polynomialCoefficients;

  LinearFeedbackShiftRegister(List<int> polynomialCoefficients,
      [List<int>? seed]) {
    setSeed(seed ?? getRandomSeed(polynomialCoefficients.length - 1));
    this.polynomialCoefficients = polynomialCoefficients;
  }

  void setSeed(List<int> seed) {
    this.seed = seed;
    register = List<int>.from(seed);
  }

  int getNext() {
    int result = 0;
    for (int i = 0; i < register.length; i++) {
      if (polynomialCoefficients[i + 1] == 1) {
        result ^= register[i];
      }
    }

    for (int i = register.length - 1; i > 0; i--) {
      register[i] = register[i - 1];
    }

    register[0] = result;
    return result;
  }

  static List<int> getRandomSeed(int length) {
    Random random = Random();
    return List<int>.generate(length, (_) => random.nextInt(2));
  }
}
