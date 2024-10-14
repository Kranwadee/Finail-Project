<?php
$db = mysqli_connect('localhost', 'root', '', 'users');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if (!$db) {
    echo json_encode("Error: Database connection failed");
    exit;
}

$email = mysqli_real_escape_string($db, $_POST['email']);
$password = mysqli_real_escape_string($db, $_POST['password']);
$phoneNumber = mysqli_real_escape_string($db, $_POST['phoneNumber']);
$studentId = mysqli_real_escape_string($db, $_POST['studentId']);

// Check if the email already exists
$sql = "SELECT id FROM users WHERE email = '$email'";
$result = mysqli_query($db, $sql);

if (mysqli_num_rows($result) > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email already exists']);
} else {
    // Insert new user
    $insert = "INSERT INTO users (email, password, phoneNumber, studentId) VALUES ('$email', '$password', '$phoneNumber', '$studentId')";
    if (mysqli_query($db, $insert)) {
        $userID = mysqli_insert_id($db);
        echo json_encode(['status' => 'success', 'userID' => $userID]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Could not insert data']);
    }
}
?>
