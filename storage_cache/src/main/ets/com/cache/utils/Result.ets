export class CacheResult<T> {
  success: boolean;
  data?: T;
  errorCode?: number;
  errorMessage?: string;

  private constructor(success: boolean, data?: T, code?: number, msg?: string) {
    this.success = success;
    this.data = data;
    this.errorCode = code;
    this.errorMessage = msg;
  }

  static ok<T>(data: T): CacheResult<T> {
    return new CacheResult<T>(true, data);
  }

  static fail<T>(code: number, msg: string): CacheResult<T> {
    return new CacheResult<T>(false, undefined, code, msg);
  }

  getOrThrow(): T {
    if (!this.success) throw new CacheError(this.errorCode!, this.errorMessage!);
    return this.data!;
  }
}

export class CacheError extends Error {
  code: number;
  constructor(code: number, message: string) {
    super(message);
    this.code = code;
    this.name = 'CacheError';
  }
}

export interface ErrorCodesType {
  DB_INSERT_FAILED: number;
  DB_QUERY_FAILED: number;
  DB_UPDATE_FAILED: number;
  DB_DELETE_FAILED: number;
  FILE_WRITE_FAILED: number;
  FILE_READ_FAILED: number;
  ENCRYPT_FAILED: number;
  DECRYPT_FAILED: number;
}

export const ErrorCodes: ErrorCodesType = {
  DB_INSERT_FAILED: 1001, DB_QUERY_FAILED: 1002,
  DB_UPDATE_FAILED: 1003, DB_DELETE_FAILED: 1004,
  FILE_WRITE_FAILED: 2001, FILE_READ_FAILED: 2002,
  ENCRYPT_FAILED: 3001, DECRYPT_FAILED: 3002,
};