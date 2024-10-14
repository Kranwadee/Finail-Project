<?php
// Connect to the database
$db = mysqli_connect('localhost', 'root', '', 'users');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Check connection
if (!$db) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit();
}

// Retrieve POST data and validate
$userId = isset($_POST['userId']) ? $_POST['userId'] : null;
$activityId = isset($_POST['activityId']) ? $_POST['activityId'] : null;

// Array to hold missing fields
$missingFields = [];

if ($userId === null) $missingFields[] = "userId";
if ($activityId === null) $missingFields[] = "activityId";

if (!empty($missingFields)) {
    echo json_encode([
        "status" => "error",
        "message" => "Error: Missing data",
        "missing_fields" => $missingFields
    ]);
    exit();
}

// Insert into useractivity table
$insert = "INSERT INTO useractivity (userId, activityId, joinTimeDate) VALUES (?, ?, NOW())";
$stmt = mysqli_prepare($db, $insert);
mysqli_stmt_bind_param($stmt, 'ii', $userId, $activityId);
if (mysqli_stmt_execute($stmt)) {
    echo json_encode(["status" => "success", "message" => "Activity joined successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error joining activity"]);
}

// Close statement and connection
mysqli_stmt_close($stmt);
mysqli_close($db);
?>
