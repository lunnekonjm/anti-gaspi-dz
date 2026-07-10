import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);
  private isInitialized = false;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
    const privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');

    if (projectId && clientEmail && privateKey) {
      try {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            clientEmail,
            // Replace literal \n with actual newlines
            privateKey: privateKey.replace(/\\n/g, '\n'),
          }),
        });
        this.isInitialized = true;
        this.logger.log(`✅ Firebase Admin initialized for project: ${projectId}`);
      } catch (error) {
        this.logger.error('Failed to initialize Firebase Admin', error);
      }
    } else {
      this.logger.warn('⚠️ Firebase credentials missing. Push notifications will be simulated.');
    }
  }

  async sendPushNotification(
    fcmToken: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<boolean> {
    if (!this.isInitialized) {
      this.logger.log(`[SIMULATED PUSH] To: ${fcmToken} | Title: ${title} | Body: ${body}`);
      return true;
    }

    try {
      const message: admin.messaging.Message = {
        token: fcmToken,
        notification: { title, body },
        data,
      };
      
      const response = await admin.messaging().send(message);
      this.logger.log(`Push notification sent successfully: ${response}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to send push notification to ${fcmToken}`, error);
      return false;
    }
  }

  async sendToTopic(
    topic: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<boolean> {
    if (!this.isInitialized) {
      this.logger.log(`[SIMULATED PUSH TOPIC] To: ${topic} | Title: ${title} | Body: ${body}`);
      return true;
    }
    try {
      const message: admin.messaging.Message = {
        topic,
        notification: { title, body },
        data,
      };
      const response = await admin.messaging().send(message);
      this.logger.log(`Push notification sent successfully to topic ${topic}: ${response}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to send push notification to topic ${topic}`, error);
      return false;
    }
  }

  async subscribeToTopic(fcmToken: string, topic: string): Promise<void> {
    if (!this.isInitialized) return;
    try {
      await admin.messaging().subscribeToTopic(fcmToken, topic);
      this.logger.log(`Token ${fcmToken} subscribed to topic ${topic}`);
    } catch (error) {
      this.logger.error(`Failed to subscribe token ${fcmToken} to topic ${topic}`, error);
    }
  }

  async unsubscribeFromTopic(fcmToken: string, topic: string): Promise<void> {
    if (!this.isInitialized) return;
    try {
      await admin.messaging().unsubscribeFromTopic(fcmToken, topic);
      this.logger.log(`Token ${fcmToken} unsubscribed from topic ${topic}`);
    } catch (error) {
      this.logger.error(`Failed to unsubscribe token ${fcmToken} from topic ${topic}`, error);
    }
  }
}
