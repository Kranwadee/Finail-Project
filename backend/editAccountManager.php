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
$password = mysqli_real_escape_string($db, $_POST['password']);
$studentId = mysqli_real_escape_string($db, $_POST['studentId']);
$isAdmin = mysqli_real_escape_string($db, $_POST['isAdmin']);

if($password == NULL){
    $sql = "UPDATE users SET phoneNumber='$phone',studentId='$studentId',password='$password',isAdmin='$isAdmin', email='$email' WHERE id='$userID'";
}else{
    $sql = "UPDATE users SET phoneNumber='$phone',studentId='$studentId',isAdmin='$isAdmin', email='$email' WHERE id='$userID'";
}

if (mysqli_query($db, $sql)) {
    echo json_encode(['status' => 'success']);
} else {
    // Capture the error message from MySQL
    $error = mysqli_error($db);
    echo json_encode(['status' => 'error', 'message' => 'Failed to update profile', 'error' => $error]);
}
?>
