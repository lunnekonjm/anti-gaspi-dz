import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';

@Injectable()
export class UploadsService {
  private readonly logger = new Logger(UploadsService.name);

  async uploadImage(file: Express.Multer.File, folder: string = 'general'): Promise<string> {
    if (!file) {
      throw new HttpException('No file provided', HttpStatus.BAD_REQUEST);
    }

    // Basic validation
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedMimeTypes.includes(file.mimetype)) {
      throw new HttpException('Invalid file type', HttpStatus.BAD_REQUEST);
    }

    try {
      const bucket = admin.storage().bucket();
      const ext = path.extname(file.originalname);
      const filename = `${folder}/${uuidv4()}${ext}`;
      const fileUpload = bucket.file(filename);

      await fileUpload.save(file.buffer, {
        metadata: {
          contentType: file.mimetype,
        },
        public: true, // Make the file publicly readable
      });

      // Construct the public URL
      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;
      this.logger.log(`File uploaded successfully: ${publicUrl}`);
      return publicUrl;
    } catch (error) {
      this.logger.error('Error uploading file to Firebase Storage', error);
      throw new HttpException('File upload failed', HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
