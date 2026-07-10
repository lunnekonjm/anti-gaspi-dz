import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Report, ReportStatus, Reservation, Donation } from '../database/entities';
import { CreateReportDto } from './dto';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Report)
    private readonly reportRepository: Repository<Report>,
    @InjectRepository(Reservation)
    private readonly reservationRepository: Repository<Reservation>,
    @InjectRepository(Donation)
    private readonly donationRepository: Repository<Donation>,
  ) {}

  async createReport(userId: string, dto: CreateReportDto): Promise<Report> {
    if (!dto.donation_id && !dto.reservation_id) {
      throw new HttpException('Must provide either donation_id or reservation_id', HttpStatus.BAD_REQUEST);
    }

    if (dto.reservation_id) {
      const res = await this.reservationRepository.findOne({ where: { id: dto.reservation_id } });
      if (!res) throw new HttpException('Reservation not found', HttpStatus.NOT_FOUND);
      // Consumer reporting merchant, or Merchant reporting consumer
      // Allow if user is either part of the reservation
    }

    if (dto.donation_id) {
      const don = await this.donationRepository.findOne({ where: { id: dto.donation_id } });
      if (!don) throw new HttpException('Donation not found', HttpStatus.NOT_FOUND);
    }

    const report = this.reportRepository.create({
      reporter_id: userId,
      donation_id: dto.donation_id,
      reservation_id: dto.reservation_id,
      reason: dto.reason,
    });

    return this.reportRepository.save(report);
  }

  async getAllReports(): Promise<Report[]> {
    return this.reportRepository.find({
      relations: { reporter: true, donation: true, reservation: true },
      order: { created_at: 'ASC' },
    });
  }

  async updateReportStatus(reportId: string, status: ReportStatus): Promise<Report> {
    const report = await this.reportRepository.findOne({ where: { id: reportId } });
    if (!report) {
      throw new HttpException('Report not found', HttpStatus.NOT_FOUND);
    }

    report.status = status;
    return this.reportRepository.save(report);
  }
}
