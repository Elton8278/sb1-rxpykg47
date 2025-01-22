import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { ShoppingBag, User, Headphones, LogOut } from 'lucide-react';
import { supabase } from '../lib/supabase';
import LanguageSelector from './LanguageSelector';
import { useTranslation } from 'react-i18next';

const Navbar = () => {
  const navigate = useNavigate();
  const [user, setUser] = React.useState(null);
  const { t } = useTranslation();

  React.useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user || null);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user || null);
    });

    return () => subscription.unsubscribe();
  }, []);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/login');
  };

  return (
    <nav className="bg-white shadow-lg">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <Link to="/" className="flex items-center space-x-2">
            <ShoppingBag className="h-8 w-8 text-indigo-600" />
            <span className="text-2xl font-bold text-gray-900">Bazam</span>
          </Link>

          <div className="flex items-center space-x-4">
            <LanguageSelector />
            {user ? (
              <>
                <Link to="/dashboard" className="text-gray-600 hover:text-gray-900">
                  <User className="h-6 w-6" />
                </Link>
                <Link to="/support" className="text-gray-600 hover:text-gray-900">
                  <Headphones className="h-6 w-6" />
                </Link>
                <button
                  onClick={handleLogout}
                  className="text-gray-600 hover:text-gray-900"
                >
                  <LogOut className="h-6 w-6" />
                </button>
              </>
            ) : (
              <div className="space-x-4">
                <Link
                  to="/login"
                  className="text-gray-600 hover:text-gray-900"
                >
                  {t('login')}
                </Link>
                <Link
                  to="/register"
                  className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700"
                >
                  {t('register')}
                </Link>
              </div>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}