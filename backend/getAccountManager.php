<?php
$db = mysqli_connect('localhost', 'root', '', 'users');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');


if (!$db) {
    echo json_encode("Error: Database connection failed");
    exit;
}

$account = mysqli_real_escape_string($db, $_POST['id']);

// Find INPUT MATCH WHICH ROW
$sql = "SELECT * FROM users WHERE id = '$account' OR phoneNumber = '$account' OR studentId = '$account' ";

$result = mysqli_query($db, $sql);

if ($result && mysqli_num_rows($result) > 0) {
    $user = mysqli_fetch_assoc($result);
    echo json_encode([
        'status' => 'success',
        'userID' => $user['id'],
        'phoneNumber' => $user['phoneNumber'],
        'studentId' => $user['studentId'],
        'isAdmin' => $user['isAdmin'],
        'email' => $user['email'],
    
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid email or password']);
}
?>
