// This script automates the process of unblocking all users currently present in the account’s blocked list

async function unblockProcess() {
    let currentCsrfToken = ""; 
    try {
        const listResponse = await fetch("https://apis.roblox.com/user-blocking-api/v1/users/get-blocked-users?cursor=&count=50", {
            method: "GET",
            credentials: "include"
        });
        const listData = await listResponse.json();
        const userIds = listData.data.blockedUserIds;
        if (!userIds || userIds.length === 0) {
            console.log("No blocked users found");
            return;
        }
        for (const userId of userIds) {
            const sendRequest = async (token) => {
                return await fetch(`https://apis.roblox.com/user-blocking-api/v1/users/${userId}/unblock-user`, {
                    method: "POST",
                    credentials: "include",
                    headers: {
                        "Accept": "application/json",
                        "Content-Type": "application/json",
                        "x-csrf-token": token,
                    },
                    body: JSON.stringify({})
                });
            };
            let response = await sendRequest(currentCsrfToken);
            if (response.status === 403) {
                const newToken = response.headers.get("x-csrf-token");
                if (newToken) {
                    currentCsrfToken = newToken;
                    response = await sendRequest(currentCsrfToken);
                }
            }
            if (response.ok) {
                console.log(`Unblocked user ${userId}.`);
            } else {
                console.log(`Failed to unblock user ${userId} (${response.status}).`);
            }
            await new Promise(r => setTimeout(r, 500));
        }
        console.log("Process completed.");
    } catch (error) {
        console.error("Unexpected error:", error);
    }
}

unblockProcess();
