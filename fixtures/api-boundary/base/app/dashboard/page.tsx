import { fetchSession } from '../../lib/api';

export default async function DashboardPage() {
  const session = await fetchSession();

  return (
    <main>
      <h1>Dashboard</h1>
      <p>Signed in.</p>
    </main>
  );
}
