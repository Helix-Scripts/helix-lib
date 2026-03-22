import { ThemeProvider } from './theme/ThemeProvider';
import { ToastProvider } from './components';

function App() {
  return (
    <ThemeProvider>
      <ToastProvider>
        <div id="helix-app">{/* Application content renders here */}</div>
      </ToastProvider>
    </ThemeProvider>
  );
}

export default App;
