enum NotificationType {
  prCreated, // When a purchase request is created
  prApproved, // When a purchase request is approved
  prFollowUp,
  prPartiallyFulfilled, // When part of the requested items are issued
  prFulfilled, // When the PR is fully fulfilled
  prCancelled, // When a PR is cancelled
  issuanceCreated, // When a new issuance is created for a PR
  issuanceReceived,
  generalAlert,
}