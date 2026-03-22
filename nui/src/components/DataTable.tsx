import { useState, useMemo, type ReactNode } from 'react';
import { ArrowUp, ArrowDown, ArrowUpDown } from 'lucide-react';
import styles from './DataTable.module.css';

export interface Column<T> {
  /** Unique key matching a property in the data objects */
  key: string;
  /** Column header label */
  header: string;
  /** Enable sorting for this column */
  sortable?: boolean;
  /** Optional custom cell renderer */
  render?: (row: T) => ReactNode;
}

export interface DataTableProps<T extends Record<string, unknown>> {
  /** Column configuration */
  columns: Column<T>[];
  /** Array of data rows */
  data: T[];
  /** Enable a global text filter */
  filterable?: boolean;
  /** Placeholder text for the filter input */
  filterPlaceholder?: string;
}

type SortDir = 'asc' | 'desc';

/**
 * Data table with sortable columns and optional global text filter.
 */
export function DataTable<T extends Record<string, unknown>>({
  columns,
  data,
  filterable = false,
  filterPlaceholder = 'Filter...',
}: DataTableProps<T>) {
  const [sortKey, setSortKey] = useState<string | null>(null);
  const [sortDir, setSortDir] = useState<SortDir>('asc');
  const [filter, setFilter] = useState('');

  const handleSort = (key: string) => {
    if (sortKey === key) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(key);
      setSortDir('asc');
    }
  };

  const processed = useMemo(() => {
    let rows = [...data];

    /* Filter */
    if (filter) {
      const lower = filter.toLowerCase();
      rows = rows.filter((row) =>
        columns.some((col) => {
          const val = row[col.key];
          return val != null && String(val).toLowerCase().includes(lower);
        }),
      );
    }

    /* Sort */
    if (sortKey) {
      rows.sort((a, b) => {
        const av = a[sortKey];
        const bv = b[sortKey];
        if (av == null && bv == null) return 0;
        if (av == null) return 1;
        if (bv == null) return -1;
        const cmp =
          typeof av === 'number' && typeof bv === 'number'
            ? av - bv
            : String(av).localeCompare(String(bv));
        return sortDir === 'asc' ? cmp : -cmp;
      });
    }

    return rows;
  }, [data, columns, filter, sortKey, sortDir]);

  const renderSortIcon = (key: string) => {
    if (sortKey !== key) return <ArrowUpDown size={12} />;
    return sortDir === 'asc' ? <ArrowUp size={12} /> : <ArrowDown size={12} />;
  };

  return (
    <div className={styles.wrapper}>
      {filterable && (
        <input
          className={styles.filterInput}
          placeholder={filterPlaceholder}
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
        />
      )}
      <table className={styles.table}>
        <thead>
          <tr>
            {columns.map((col) => (
              <th
                key={col.key}
                className={[styles.th, col.sortable && styles.sortable]
                  .filter(Boolean)
                  .join(' ')}
                onClick={col.sortable ? () => handleSort(col.key) : undefined}
              >
                {col.header}
                {col.sortable && (
                  <span className={styles.sortIcon}>
                    {renderSortIcon(col.key)}
                  </span>
                )}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {processed.length === 0 ? (
            <tr>
              <td className={styles.empty} colSpan={columns.length}>
                No data
              </td>
            </tr>
          ) : (
            processed.map((row, i) => (
              <tr key={i} className={styles.tr}>
                {columns.map((col) => (
                  <td key={col.key} className={styles.td}>
                    {col.render
                      ? col.render(row)
                      : (row[col.key] as ReactNode)}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
