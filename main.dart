import 'dart:math';

void main() {
  String message = '111010011100'; // The message to be encrypted
  List<int> key = [1, 0, 0, 1]; // The encryption key
  List<int> seed = [0, 0, 1, 0]; // The seed for the linear feedback shift register
  key.insert(0, 1); // Add an additional bit to the key

  // Create encryption and decryption ciphers using the same key and seed
  SynchronousStreamCipher encryptionCipher = SynchronousStreamCipher(key, seed);
  SynchronousStreamCipher decryptionCipher = SynchronousStreamCipher(key, seed);

  // Encrypt the message using the encryption cipher
  String encryptedMessage = encryptionCipher.encrypt(message);

  // Decrypt the encrypted message using the decryption cipher
  String decryptedMessage = decryptionCipher.encrypt(encryptedMessage);

  // Print the original message, encrypted message, and decrypted message
  print('Original: $message');
  print('Encrypted: $encryptedMessage');
  print('Decrypted: $decryptedMessage');
}

// Class representing a synchronous stream cipher
class SynchronousStreamCipher {
  late LinearFeedbackShiftRegister encryptionRegister;

  SynchronousStreamCipher(List<int> coefficients, List<int> seed) {
    encryptionRegister = LinearFeedbackShiftRegister(coefficients, seed);
  }

  // Encrypts a message using the encryption register
  String encrypt(String message) {
    return String.fromCharCodes(message.runes.map((charCode) {
      int bit =
          charCode == 49 ? 1 : 0; // Convert ASCII value to binary (1 or 0)
      int encryptedBit = bit ^
          encryptionRegister
              .getNext(); // XOR the bit with the next value from the encryption register
      return encryptedBit == 1
          ? 49
          : 48; // Convert encrypted bit back to ASCII value
    }));
  }
}

// Class representing a linear feedback shift register
class LinearFeedbackShiftRegister {
  late List<int> register;
  late List<int> seed;
  late List<int> polynomialCoefficients;

  // Initialize the linear feedback shift register with given polynomial coefficients and optional seed
  LinearFeedbackShiftRegister(List<int> polynomialCoefficients,
      [List<int>? seed]) {
    setSeed(seed ??
        getRandomSeed(polynomialCoefficients.length -
            1)); // If seed is not provided, generate a random one
    this.polynomialCoefficients = polynomialCoefficients;
  }

  // Set the seed for the linear feedback shift register
  void setSeed(List<int> seed) {
    this.seed = seed;
    register = List<int>.from(seed);
  }

  // Get the next bit from the linear feedback shift register
  int getNext() {
    int result = 0;
    for (int i = 0; i < register.length; i++) {
      if (polynomialCoefficients[i + 1] == 1) {
        result ^= register[i]; // XOR the bit with the corresponding coefficient
      }
    }

    for (int i = register.length - 1; i > 0; i--) {
      register[i] = register[i - 1]; // Shift the bits to the right
    }

    register[0] = result; // Update the first bit with the result
    return result;
  }

  // Generate a random seed of given length
  static List<int> getRandomSeed(int length) {
    Random random = Random();
    return List<int>.generate(length,
        (_) => random.nextInt(2)); // Generate a list of random bits (0 or 1)
  }
}
