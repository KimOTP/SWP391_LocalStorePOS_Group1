function handleApproval(type, id, isApprove) {
    const confirmMsg = isApprove ? "Approve this request?" : "Reject this request?";
    if (confirm(confirmMsg)) {
        document.getElementById('actionType').value = type;
        document.getElementById('actionId').value = id;
        document.getElementById('isApprove').value = isApprove;
        document.getElementById('actionForm').submit();
    }
}