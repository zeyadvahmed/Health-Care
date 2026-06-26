import '../models/hydration_entry_model.dart';
import 'firestore_service.dart';

class RemoteHydrationService {

  RemoteHydrationService._internal();
  static final RemoteHydrationService instance =
      RemoteHydrationService._internal();

  String _hydrationEntriesPath(String uid) =>
      'users/$uid/hydration_entries';

  Future<void> pushEntry(
    HydrationEntryModel entry,
    String uid,
  ) async {
    await FirestoreService.instance.setDocument(
      _hydrationEntriesPath(uid),
      entry.id,
      entry.toFirestore(),
    );
  }

  Future<void> deleteEntry(
    String id,
    String uid,
  ) async {
    await FirestoreService.instance.deleteDocument(
      _hydrationEntriesPath(uid),
      id,
    );
  }

  Future<List<HydrationEntryModel>> fetchEntriesForUser(
    String uid,
  ) async {
    final docs = await FirestoreService.instance.getCollection(
      _hydrationEntriesPath(uid),
      // No filter — subcollection is already scoped to this user
    );
    return docs
        .map((doc) => HydrationEntryModel.fromFirestore(doc))
        .toList();
  }
}
