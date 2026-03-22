import styles from './ProgressBar.module.css';

export interface ProgressBarProps {
  /** Current value 0-100 */
  value: number;
  /** Show percentage label */
  showLabel?: boolean;
  /** Visual variant */
  variant?: 'linear' | 'circular';
  /** Size of circular variant in px */
  size?: number;
  /** Track thickness for circular variant */
  strokeWidth?: number;
}

/**
 * Progress indicator in linear (bar) or circular (ring) form.
 */
export function ProgressBar({
  value,
  showLabel = false,
  variant = 'linear',
  size = 48,
  strokeWidth = 4,
}: ProgressBarProps) {
  const clamped = Math.max(0, Math.min(100, value));

  if (variant === 'circular') {
    const radius = (size - strokeWidth) / 2;
    const circumference = 2 * Math.PI * radius;
    const offset = circumference - (clamped / 100) * circumference;

    return (
      <div className={styles.circular} style={{ width: size, height: size }}>
        <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
          <circle
            className={styles.circularTrack}
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            strokeWidth={strokeWidth}
          />
          <circle
            className={styles.circularFill}
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            strokeWidth={strokeWidth}
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            strokeLinecap="round"
            transform={`rotate(-90 ${size / 2} ${size / 2})`}
          />
        </svg>
        {showLabel && (
          <span className={styles.circularLabel}>{Math.round(clamped)}%</span>
        )}
      </div>
    );
  }

  return (
    <div className={styles.wrapper} role="progressbar" aria-valuenow={clamped} aria-valuemin={0} aria-valuemax={100}>
      <div className={styles.track}>
        <div className={styles.fill} style={{ width: `${clamped}%` }} />
      </div>
      {showLabel && (
        <span className={styles.label}>{Math.round(clamped)}%</span>
      )}
    </div>
  );
}
