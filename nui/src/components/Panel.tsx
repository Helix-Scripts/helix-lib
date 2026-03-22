import {
  useRef,
  useCallback,
  useState,
  type ReactNode,
  type CSSProperties,
  type HTMLAttributes,
} from 'react';
import { X } from 'lucide-react';
import styles from './Panel.module.css';

export interface PanelProps extends HTMLAttributes<HTMLDivElement> {
  /** Optional panel title shown in the header */
  title?: string;
  /** Allow dragging the panel by its header */
  draggable?: boolean;
  /** Show a close button in the header */
  onClose?: () => void;
  /** Initial top/left position */
  position?: { x: number; y: number };
  children?: ReactNode;
}

/**
 * Absolutely-positioned panel container with optional draggable header and close button.
 */
export function Panel({
  title,
  draggable: isDraggable = false,
  onClose,
  position,
  children,
  style,
  className,
  ...rest
}: PanelProps) {
  const panelRef = useRef<HTMLDivElement>(null);
  const [offset, setOffset] = useState({ x: position?.x ?? 0, y: position?.y ?? 0 });
  const dragState = useRef<{ startX: number; startY: number; ox: number; oy: number } | null>(null);

  const onPointerDown = useCallback(
    (e: React.PointerEvent) => {
      if (!isDraggable) return;
      dragState.current = {
        startX: e.clientX,
        startY: e.clientY,
        ox: offset.x,
        oy: offset.y,
      };
      (e.target as HTMLElement).setPointerCapture(e.pointerId);
    },
    [isDraggable, offset],
  );

  const onPointerMove = useCallback((e: React.PointerEvent) => {
    if (!dragState.current) return;
    const dx = e.clientX - dragState.current.startX;
    const dy = e.clientY - dragState.current.startY;
    setOffset({ x: dragState.current.ox + dx, y: dragState.current.oy + dy });
  }, []);

  const onPointerUp = useCallback(() => {
    dragState.current = null;
  }, []);

  const showHeader = title || onClose;
  const positionStyle: CSSProperties = {
    left: offset.x,
    top: offset.y,
    ...style,
  };

  return (
    <div
      ref={panelRef}
      className={[styles.panel, className].filter(Boolean).join(' ')}
      style={positionStyle}
      {...rest}
    >
      {showHeader && (
        <div
          className={[styles.header, isDraggable && styles.draggable]
            .filter(Boolean)
            .join(' ')}
          onPointerDown={onPointerDown}
          onPointerMove={onPointerMove}
          onPointerUp={onPointerUp}
        >
          {title && <span className={styles.title}>{title}</span>}
          {onClose && (
            <button
              className={styles.closeBtn}
              onClick={onClose}
              aria-label="Close panel"
            >
              <X size={16} />
            </button>
          )}
        </div>
      )}
      <div className={styles.body}>{children}</div>
    </div>
  );
}
