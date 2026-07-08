/**
 * Common enums shared across the anti-gaspi-dz platform.
 * These mirror the database enum types exactly.
 */

export enum UserRole {
  CONSUMER = 'consumer',
  MERCHANT = 'merchant',
  ASSOCIATION = 'association',
  ADMIN = 'admin',
}

export enum Language {
  AR = 'ar',
  FR = 'fr',
}

export enum OfferStatus {
  DRAFT = 'draft',
  ACTIVE = 'active',
  SOLD_OUT = 'sold_out',
  EXPIRED = 'expired',
  CANCELLED = 'cancelled',
}

export enum ExpiryType {
  /** Date Limite de Consommation — hard block, safety critical */
  DLC = 'DLC',
  /** Date de Durabilité Minimale — advisory, tolerance displayed */
  DDM = 'DDM',
}

export enum ReservationStatus {
  PENDING_PAYMENT = 'pending_payment',
  CONFIRMED = 'confirmed',
  PICKED_UP = 'picked_up',
  CANCELLED = 'cancelled',
  NO_SHOW = 'no_show',
}

export enum DonationStatus {
  AVAILABLE = 'available',
  RESERVED = 'reserved',
  COMPLETED = 'completed',
  REPORTED = 'reported',
}

export enum InstitutionalDonationStatus {
  ANNOUNCED = 'announced',
  ACCEPTED = 'accepted',
  TRANSFERRED = 'transferred',
  COMPLETED = 'completed',
}

export enum CommissionType {
  PERCENTAGE = 'percentage',
  FIXED = 'fixed',
}

export enum PaymentProvider {
  MOCK = 'mock',
  SATIM = 'satim',
  BARIDIMOB = 'baridimob',
}
