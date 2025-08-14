abstract class HomeEvent {}

class FetchBooking extends HomeEvent {
  int userProfileSno;
  int status;
  int skip;
  int limits;
  FetchBooking(
      {required this.userProfileSno,
      required this.status,
      required this.skip,
      required this.limits});
}
