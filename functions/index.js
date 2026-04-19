

const {setGlobalOptions} = require("firebase-functions");

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
setGlobalOptions({maxInstances: 10});


// 1️⃣ إشعار عند إضافة عقد جديد
exports.newContractNotification = functions.firestore
    .document("contracts/{contractId}")
    .onCreate(async (snap, context) => {
      const contract = snap.data();

      const message = {
        topic: "all_users",
        notification: {
          title: "عقد جديد",
          body: contract.title || "تم إضافة عقد جديد",
        },
        data: {
          type: "new_contract",
          contractId: context.params.contractId,
        },
      };

      await admin.messaging().send(message);
    });


// 2️⃣ إشعار رسالة جديدة
exports.newMessageNotification = functions.firestore
    .document("messages/{messageId}")
    .onCreate(async (snap, context) => {
      const messageData = snap.data();

      const receiverId = messageData.receiverId;

      const userDoc = await db.collection("users").doc(receiverId).get();

      const token = userDoc.data().fcm_token;

      if (!token) return;

      const message = {
        token: token,
        notification: {
          title: "رسالة جديدة",
          body: messageData.text || "لديك رسالة جديدة",
        },
        data: {
          type: "new_message",
          chatId: messageData.chatId,
        },
      };

      await admin.messaging().send(message);
    });


// 3️⃣ إشعار اكتمال العقد
exports.contractCompletedNotification = functions.firestore
    .document("contracts/{contractId}")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      if (before.status === 2) return;

      if (after.status === 2) {
        const ownerId = after.ownerId;

        const userDoc = await db.collection("users").doc(ownerId).get();

        const token = userDoc.data().fcm_token;

        if (!token) return;

        const message = {
          token: token,
          notification: {
            title: "تم اكتمال العقد",
            body: "تم تنفيذ العقد بنجاح",
          },
          data: {
            type: "contract_completed",
            contractId: context.params.contractId,
          },
        };

        await admin.messaging().send(message);
      }
    });


// 4️⃣ إشعار تغير العضوية
exports.membershipChangedNotification = functions.firestore
    .document("users/{userId}")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      if (before.membership === after.membership) return;

      const token = after.fcm_token;

      if (!token) return;

      const message = {
        token: token,
        notification: {
          title: "تحديث العضوية",
          body: `تم تحديث عضويتك إلى ${after.membership}`,
        },
        data: {
          type: "membership_changed",
        },
      };

      await admin.messaging().send(message);
    });
