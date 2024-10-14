<?php
$db = mysqli_connect('localhost', 'root', '', 'users');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

if (!$db) {
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
    exit;
}

// Get the userID from the POST request
$userID = $_POST['userID'] ?? '';

if (empty($userID)) {
    echo json_encode(['status' => 'error', 'message' => 'User ID is required']);
    exit;
}

// Modify the SQL query to filter activities by userID
$sql = "
    SELECT 
        a.id AS activity_id,
        a.title,
        a.imagePath,
        a.description,
        a.isJoinable,
        a.scoreType,
        a.score,
        a.event_dateTime,
        a.location,
        ua.userId,
        ua.joinTimeDate,
        u.email,
        u.phoneNumber,
        u.studentId
    FROM activity a
    LEFT JOIN userActivity ua ON a.id = ua.activityId
    LEFT JOIN users u ON ua.userId = u.id
    WHERE ua.userId = '$userID'
";

$result = mysqli_query($db, $sql);

$activities = [];

if ($result && mysqli_num_rows($result) > 0) {
    while ($row = mysqli_fetch_assoc($result)) {
        // Check if activity already exists in the activities array
        if (!isset($activities[$row['activity_id']])) {
            $activities[$row['activity_id']] = [
                'id' => $row['activity_id'],
                'title' => $row['title'],
                'imagePath' => $row['imagePath'],
                'description' => $row['description'],
                'isJoinable' => $row['isJoinable'] == '1',
                'category' => $row['scoreType'],
                'score' => $row['score'],
                'datetime' => $row['event_dateTime'],
                'location' => $row['location'],
                'participants' => [] // Initialize participants array
            ];
        }

        // Add participant information if available
        if ($row['userId']) {
            $activities[$row['activity_id']]['participants'][] = [
                'userId' => $row['userId'],
                'joinTimeDate' => $row['joinTimeDate'],
                'email' => $row['email'],
                'phoneNumber' => $row['phoneNumber'],
                'studentId' => $row['studentId']
            ];
        }
    }

    echo json_encode(['status' => 'success', 'activities' => array_values($activities)]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'No activities found']);
}
?>
