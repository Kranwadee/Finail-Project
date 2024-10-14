<?php
$db = mysqli_connect('localhost', 'root', '', 'users');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

if (!$db) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

$userID = mysqli_real_escape_string($db, $_POST['userID']);
$phone = mysqli_real_escape_string($db, $_POST['phone']);
$email = mysqli_real_escape_string($db, $_POST['email']);

$sql = "UPDATE users SET phoneNumber='$phone', email='$email' WHERE id='$userID'";
if (mysqli_query($db, $sql)) {
    echo json_encode(['status' => 'success']);
} else {
    // Capture the error message from MySQL
    $error = mysqli_error($db);
    echo json_encode(['status' => 'error', 'message' => 'Failed to update profile', 'error' => $error]);
}
?>
