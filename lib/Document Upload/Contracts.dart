/*import 'dart:io';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:path/path.dart' show join, dirname;
import 'package:web_socket_channel/io.dart';

const String rpcUrl = 'http://localhost:7545';
const String wsUrl = 'ws://localhost:7545';

const String privateKey =
    '85d2242ae1b7759934d4b0d4f0d62d666cf7d73e21dbd09d73c7de266b72a25a';

final EthereumAddress contractAddr =
EthereumAddress.fromHex('0xf451659CF5688e31a31fC3316efbcC2339A490Fb');
final EthereumAddress receiver =
EthereumAddress.fromHex('0x6c87E1a114C3379BEc929f6356c5263d62542C13');

final File abiFile =
File(join(dirname(Platform.script.path), 'DocumentVerifier_compData.json'));

void main() async {
  try {
    final client = Web3Client(rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });

    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final ownAddress = await credentials.extractAddress();

    final abiCode = await abiFile.readAsString();
    final contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'DocumentVerifier'), contractAddr);

    // Replace with the actual functions and events from DocumentVerifier.
    final verifyDocumentFunction = contract.function('verifyDocument'); //Example function name.
    final documentVerifiedEvent = contract.event('DocumentVerified'); //Example event name.

    final subscription = client
        .events(FilterOptions.events(
        contract: contract, event: documentVerifiedEvent))
        .take(1)
        .listen((event) {
      final decoded = documentVerifiedEvent.decodeResults(event.topics! + [event.data!]);
      // Handle decoded event data.
      print('Document verified event received: $decoded');
    });

    // Example call to verifyDocument function.
    final result = await client.call(
        contract: contract,
        function: verifyDocumentFunction,
        params: ['documentHash']);

    print('Verification result: $result');

    // Example transaction to verify document.
    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: verifyDocumentFunction,
        parameters: ['documentHash'],
      ),
    );

    await subscription.asFuture();
    await subscription.cancel();

    await client.dispose();
  } catch (e) {
    print('An error occurred: $e');
  }
}*/