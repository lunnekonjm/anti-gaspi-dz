import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MerchantRequest, MerchantRequestStatus, User } from '../database/entities';
import { UserRole } from '../common/enums';
import { CreateMerchantRequestDto } from './dto';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class MerchantsService {
  private readonly logger = new Logger(MerchantsService.name);

  constructor(
    @InjectRepository(MerchantRequest)
    private readonly requestRepository: Repository<MerchantRequest>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly notificationsService: NotificationsService,
  ) {}

  async createRequest(userId: string, dto: CreateMerchantRequestDto): Promise<MerchantRequest> {
    const existingRequest = await this.requestRepository.findOne({
      where: { user_id: userId, status: MerchantRequestStatus.PENDING },
    });

    if (existingRequest) {
      throw new HttpException(
        'Vous avez déjà une demande en cours.',
        HttpStatus.BAD_REQUEST,
      );
    }

    const request = this.requestRepository.create({
      user_id: userId,
      ...dto,
    });

    return this.requestRepository.save(request);
  }

  async getPendingRequests(): Promise<MerchantRequest[]> {
    return this.requestRepository.find({
      where: { status: MerchantRequestStatus.PENDING },
      relations: { user: true },
      order: { created_at: 'ASC' },
    });
  }

  async approveRequest(requestId: string): Promise<MerchantRequest> {
    const request = await this.requestRepository.findOne({
      where: { id: requestId },
      relations: { user: true },
    });

    if (!request) {
      throw new HttpException('Request not found', HttpStatus.NOT_FOUND);
    }

    if (request.status !== MerchantRequestStatus.PENDING) {
      throw new HttpException('Request already processed', HttpStatus.BAD_REQUEST);
    }

    request.status = MerchantRequestStatus.APPROVED;
    const savedRequest = await this.requestRepository.save(request);

    // Update user role to MERCHANT and is_verified to true
    if (request.user) {
      await this.userRepository.update(request.user.id, {
        role: UserRole.MERCHANT,
        is_verified: true,
      });

      // Send push notification to user
      if (request.user.fcm_token) {
        await this.notificationsService.sendPushNotification(
          request.user.fcm_token,
          'Compte Commerçant Validé !',
          'Votre demande pour devenir commerçant a été approuvée. Vous pouvez maintenant publier des offres.',
        );
      }
    }

    return savedRequest;
  }

  async rejectRequest(requestId: string): Promise<MerchantRequest> {
    const request = await this.requestRepository.findOne({
      where: { id: requestId },
      relations: { user: true },
    });

    if (!request) {
      throw new HttpException('Request not found', HttpStatus.NOT_FOUND);
    }

    if (request.status !== MerchantRequestStatus.PENDING) {
      throw new HttpException('Request already processed', HttpStatus.BAD_REQUEST);
    }

    request.status = MerchantRequestStatus.REJECTED;
    const savedRequest = await this.requestRepository.save(request);

    // Send push notification to user
    if (request.user?.fcm_token) {
      await this.notificationsService.sendPushNotification(
        request.user.fcm_token,
        'Demande Refusée',
        'Votre demande pour devenir commerçant a été refusée. Veuillez contacter le support pour plus de détails.',
      );
    }

    return savedRequest;
  }
}
